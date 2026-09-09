###############################################################################
# TASK: build_offline
#
# build a CollectionBuilder site and replace links for offline use
#
# generates the Jekyll site, downloads external media (images, pdfs), 
# and rewrites all internal links so the site works from the local filesystem without a server.
#
# options (passed as rake arguments, e.g. rake build_offline[true,offline_site,assets/lib,false]):
#   download_external - download external media linked in metadata, true/false (default: true)
#   output_dir        - directory name for the offline output (default: "offline_site")
#   skip_rewrite      - comma separated directories to skip rewriting, useful for external libraries that should not be modified (default: "lib-assets" value from _config.yml, usually "assets/lib")
#   download_video    - also download directly hosted video files (mp4, webm, etc.), true/false (default: false)
#
# see docs/rake_tasks/build_offline.md for full documentation
###############################################################################

require 'csv'
require 'digest'
require 'net/http'
require 'open-uri'
require 'pathname'
require 'set'
require 'tempfile'
require 'uri'
require 'yaml'

# file types to download for offline use by default (images, pdfs, audio)
OFFLINE_MEDIA_EXTENSIONS = %w[.jpg .jpeg .png .gif .tif .tiff .pdf .mp3 .wav .ogg .m4a].freeze

# video file types, only downloaded when the download_video option is true.
# streaming platforms (YouTube, Vimeo, etc.) have no file extension so are never downloaded.
OFFLINE_VIDEO_EXTENSIONS = %w[.mp4 .webm .ogv .mov].freeze

# metadata field => [objects subdirectory, filename suffix] for downloaded files.
# downloads are named by objectid following CB conventions, e.g. objects/small/demo_001_sm.jpg
OFFLINE_MEDIA_FIELDS = {
  'object_location' => ['objects', ''],
  'image_small'     => ['objects/small', '_sm'],
  'image_thumb'     => ['objects/thumbs', '_th']
}.freeze

# check whether the URL points to a file type eligible for offline download
def offline_downloadable?(url, extensions)
  ext = File.extname(URI.parse(url).path).downcase
  extensions.include?(ext)
rescue URI::InvalidURIError
  false
end

# build a local filename for a downloaded file.
# uses objectid + suffix + original extension; rows without objectid fall back to the
# original basename plus a short hash of the url to avoid collisions.
def offline_dest_filename(objectid, url, suffix)
  path = URI.parse(url).path
  ext = File.extname(path).downcase
  id = objectid.to_s.strip
  if id.empty?
    "#{File.basename(path, '.*')}_#{Digest::MD5.hexdigest(url)[0, 8]}#{suffix}#{ext}"
  else
    "#{id}#{suffix}#{ext}"
  end
end

# download a file from url and save to dest_path; returns true on success
def offline_download(url, dest_path)
  puts "Downloading: #{url}"
  URI.open(url, 'rb', open_timeout: 30, read_timeout: 60) do |remote|
    IO.copy_stream(remote, dest_path)
  end
  puts "  -> #{dest_path}"
  true
rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
       Net::OpenTimeout, Net::ReadTimeout, RuntimeError => e
  puts "  -> download failed: #{e.message}"
  FileUtils.rm_f(dest_path)
  false
end

# normalize a root-relative site path for the local filesystem.
# returns [site_path, tail] where site_path has no leading slash and tail is any
# fragment/query string. browsers do not resolve directories to index.html from file://,
# so "/" and "/dir/" become "index.html" and "dir/index.html".
def offline_site_path(path)
  m = path.delete_prefix('/').match(/\A([^#?]*)(.*)\z/m)
  base = m[1]
  base = 'index.html' if base.empty?
  base += 'index.html' if base.end_with?('/')
  [base, m[2]]
end

# convert a root-relative site path into a path relative to the current file.
# returns nil when the path does not point into the offline site, i.e. its first segment is
# not a top-level file or directory of the build output (top_level is a Set of names, or nil
# to skip the check). callers leave such strings untouched, which avoids rewriting quoted text
# or attribute values that merely begin with a slash.
# directory_index - apply the "/" and "/dir/" => index.html rules. only safe when the path is
#                   known to be complete; JS code often builds URLs from a prefix string such as
#                   '/items/' + id, where appending index.html would corrupt the result.
def offline_localize(path, prefix, top_level, directory_index: true)
  if directory_index
    base, tail = offline_site_path(path)
  else
    base, tail = path.delete_prefix('/'), ''
  end
  first = base.split(%r{[/#?]}, 2).first.to_s
  return nil if top_level && !top_level.include?(first)
  "#{prefix}#{base}#{tail}"
end

# read a text file for rewriting; returns nil (with a warning) if it is not valid UTF-8,
# so that binary or oddly encoded files are never silently mangled
def offline_read(filepath)
  content = File.binread(filepath).force_encoding('utf-8')
  return content if content.valid_encoding?

  puts "  Warning: '#{filepath}' is not valid UTF-8, skipping"
  nil
end

# placeholder baseurl used for the offline build. every path that passes through Jekyll's
# relative_url / absolute_url filters is prefixed with it, so the rewrite only has to replace
# this one token rather than guess which strings in the rendered output are site paths.
OFFLINE_SENTINEL = '/__CB_OFFLINE_ROOT__'.freeze

# file types that may contain the sentinel (anything Jekyll renders through Liquid)
OFFLINE_REWRITE_EXTENSIONS = %w[html js css json xml csv txt svg webmanifest].freeze

# rewrite all internal links in a file's content for local filesystem use.
# depth     - number of directory levels below the offline root (0 = root-level files)
# url_map   - hash of { external_url => root_relative_local_path } for downloaded media
# top_level - Set of top-level names in the build output, used to gate the fallback rewrite of
#             hardcoded root-relative attribute paths (nil disables the fallback)
# type      - file extension as a symbol; controls how the sentinel is resolved. :html and :css
#             get a prefix relative to the file's own location (browsers resolve both against
#             the file itself). every other type gets a root-relative path: a standalone JS file
#             resolves against whichever page loads it, and data exports are not navigated.
def offline_rewrite_links(content, depth, url_map, top_level = nil, type: :html)
  prefix = '../' * depth
  # absolute_url output carries the site host in front of the sentinel when url is set
  sentinel = %r{(?:https?://[^/"'\s]+)?#{Regexp.escape(OFFLINE_SENTINEL)}}

  # 1. replace downloaded external media URLs with relative local paths
  url_map.each do |external_url, local_path|
    content = content.gsub(external_url, "#{prefix}#{local_path.delete_prefix('/')}")
  end

  # 2. sentinel paths in complete HTML attribute values get the directory => index.html rules,
  #    since "/" and "/search/" do not resolve without a server. the value is bounded by its own
  #    opening quote so the other quote type may appear inside it. a closing quote followed by
  #    "+" marks a JS string prefix such as href="/items/" + id, which must keep its slash.
  if type == :html
    content = content.gsub(/((?:href|src|action|content|xlink:href|data-src|data|poster)=)(["'])#{sentinel}(\/.*?)\2(?=(\s*\+)?)/) do
      attr, quote, path, concat = $1, $2, $3, $4
      "#{attr}#{quote}#{offline_localize(path, prefix, nil, directory_index: concat.nil?)}#{quote}"
    end
  end

  # 3. every remaining sentinel becomes a plain prefix: JS strings and template literals,
  #    inline JSON, CSS url(), meta content, and data files
  root = %i[html css].include?(type) ? prefix : '/'
  content = content.gsub(%r{#{sentinel}/}, root)
  content = content.gsub(sentinel, root.chomp('/'))

  # 4. fallback for hardcoded root-relative paths in HTML attributes that did not pass through
  #    a Liquid url filter (e.g. a markdown link written as /browse.html). only rewritten when
  #    the first segment is a top-level file or directory of the build, which leaves quoted text
  #    or attribute values that merely begin with a slash untouched.
  if type == :html && top_level
    content = content.gsub(/((?:href|src|action|content|xlink:href|data-src|data|poster)=)(["'])(\/(?!\/).*?)\2(?=(\s*\+)?)/) do
      attr, quote, path, concat = $1, $2, $3, $4
      local = offline_localize(path, prefix, top_level, directory_index: concat.nil?)
      "#{attr}#{quote}#{local || path}#{quote}"
    end
  end

  content
end

desc 'Build jekyll site and rewrite links for offline use'
task :build_offline, [:download_external, :output_dir, :skip_rewrite, :download_video] do |_t, args|
  args.with_defaults(
    download_external: 'true',
    output_dir: 'offline_site',
    download_video: 'false'
  )

  download_external = args.download_external.to_s.strip.downcase != 'false'
  offline_dir = args.output_dir.to_s.strip.chomp('/')
  abort 'output_dir cannot be empty' if offline_dir.empty?
  download_video = args.download_video.to_s.strip.downcase == 'true'
  media_extensions = download_video ? OFFLINE_MEDIA_EXTENSIONS + OFFLINE_VIDEO_EXTENSIONS : OFFLINE_MEDIA_EXTENSIONS

  # load site configuration for metadata filename, library path, and exclude list
  config = YAML.load_file('_config.yml')
  metadata_name = config['metadata']

  # directories to leave untouched by the link rewrite, comma separated.
  # defaults to the lib-assets directory from _config.yml (third-party libraries).
  # an explicit empty value (e.g. rake build_offline[true,offline_site,]) means rewrite everything.
  skip_rewrite_dirs = (args.skip_rewrite || config['lib-assets'] || 'assets/lib').to_s
                      .split(',').map { |d| d.strip.delete('"\'').delete_prefix('/').chomp('/') }.reject(&:empty?)

  # build jekyll site with the offline environment directly into the output directory.
  # a temporary config override:
  #   - sets baseurl to the sentinel token (and blanks url) so every path produced by the
  #     relative_url / absolute_url filters is marked for rewriting
  #   - adds the output directory to the exclude list so that a custom output_dir is never
  #     read back in as site content on later builds
  ENV['JEKYLL_ENV'] = 'offline'
  excludes = Array(config['exclude']).map(&:to_s)
  excludes << "#{offline_dir}/" unless excludes.include?(offline_dir) || excludes.include?("#{offline_dir}/")
  override = Tempfile.new(['offline_config', '.yml'])
  override.write({ 'baseurl' => OFFLINE_SENTINEL, 'url' => '', 'exclude' => excludes }.to_yaml)
  override.close
  begin
    system('bundle', 'exec', 'jekyll', 'build',
           '--destination', offline_dir,
           '--config', "_config.yml,#{override.path}") or abort 'Jekyll build failed'
  ensure
    override.unlink
  end

  # track { external_url => root_relative_local_path } for successfully downloaded files only,
  # so that a failed download leaves the original external link in place rather than a broken local path
  url_map = {}
  downloaded = []   # urls fetched in this run
  reused = []       # urls whose local file already existed in the build output
  failed = []       # urls that could not be downloaded
  skipped = []      # external urls in media fields left as-is (streaming, unsupported types, invalid)

  if download_external
    if metadata_name.nil? || metadata_name.strip.empty?
      puts "No 'metadata' key found in _config.yml, skipping external media download."
    else
      metadata_file = File.join('_data', "#{metadata_name}.csv")
      unless File.exist?(metadata_file)
        puts "Metadata file '#{metadata_file}' not found, skipping external media download."
      else
        puts "Scanning '#{metadata_file}' for external media to download..."
        csv_data = CSV.read(metadata_file, headers: true, encoding: 'utf-8')

        OFFLINE_MEDIA_FIELDS.each do |field, (subdir, suffix)|
          next unless csv_data.headers.include?(field)

          dest_dir = File.join(offline_dir, subdir)
          FileUtils.mkdir_p(dest_dir)

          csv_data.each do |row|
            url = row[field].to_s.strip
            next if url.empty?
            next unless url.start_with?('http')
            next if url_map.key?(url) || failed.include?(url)  # already handled from another row/field

            unless offline_downloadable?(url, media_extensions)
              skipped << url unless skipped.include?(url)
              next
            end

            filename = offline_dest_filename(row['objectid'], url, suffix)
            dest_path = File.join(dest_dir, filename)
            # root-relative path uses forward slashes regardless of OS
            root_relative = "/#{subdir}/#{filename}"

            if File.exist?(dest_path)
              # a local object with the same name was copied from the project; reuse it rather than overwrite
              puts "Warning: '#{dest_path}' already exists, using it for #{url}"
              reused << url
              url_map[url] = root_relative
            elsif offline_download(url, dest_path)
              downloaded << url
              url_map[url] = root_relative
            else
              failed << url
            end
          end
        end

        # summary of download results, also written to the output directory for reference
        summary = []
        summary << "External media download summary (#{Time.now.strftime('%Y-%m-%d %H:%M')})"
        summary << "  downloaded: #{downloaded.size}"
        summary << "  reused existing local files: #{reused.size}"
        summary << "  failed: #{failed.size}"
        summary << "  left as external links: #{skipped.size}"
        unless failed.empty?
          summary << ''
          summary << 'Failed downloads (links left pointing to the external URL):'
          failed.each { |u| summary << "  #{u}" }
        end
        unless skipped.empty?
          summary << ''
          summary << 'External links not downloaded (streaming platforms or unsupported file types):'
          skipped.each { |u| summary << "  #{u}" }
        end
        puts
        puts summary
        File.write(File.join(offline_dir, 'offline_build_log.txt'), summary.join("\n") + "\n")
      end
    end
  end

  # rewrite all links for local filesystem use by resolving the sentinel baseurl in every
  # Liquid-rendered text file (see offline_rewrite_links for how each file type is handled)
  puts "Rewriting links for offline use..."
  updated = 0
  top_level = Dir.children(offline_dir).to_set
  Dir.glob(File.join(offline_dir, '**', "*.{#{OFFLINE_REWRITE_EXTENSIONS.join(',')}}")).each do |filepath|
    rel = Pathname.new(filepath).relative_path_from(Pathname.new(offline_dir)).to_s
    # skip files inside the skip_rewrite directories (e.g. third-party libraries), matching on directory boundary
    next if skip_rewrite_dirs.any? { |d| rel == d || rel.start_with?("#{d}/") }
    depth = rel.count('/')
    type = File.extname(filepath).delete_prefix('.').downcase.to_sym
    content = offline_read(filepath)
    next if content.nil?
    new_content = offline_rewrite_links(content, depth, url_map, top_level, type: type)
    if new_content != content
      File.binwrite(filepath, new_content)
      updated += 1
    end
  end
  puts "  #{updated} file(s) updated.#{skip_rewrite_dirs.empty? ? '' : " (skipped '#{skip_rewrite_dirs.join("', '")}')"}"

  # any sentinel left behind means a file type or location the rewrite did not cover
  leftovers = Dir.glob(File.join(offline_dir, '**', '*')).select do |f|
    File.file?(f) && File.size(f) < 50_000_000 && File.binread(f).include?(OFFLINE_SENTINEL)
  end
  unless leftovers.empty?
    puts "  Warning: sentinel '#{OFFLINE_SENTINEL}' still present in #{leftovers.size} file(s):"
    leftovers.first(20).each { |f| puts "    #{f}" }
  end

  # inline SVG icon sprite: browsers block loading external SVG files in local file:// mode,
  # so we embed the full sprite as a hidden <svg> in each HTML page and rewrite all
  # href="PATH/cb-icons.svg#id" references to fragment-only href="#id".
  # this handles both static <use> elements in HTML and dynamically-built icon strings in JS.
  puts "Inlining SVG icon sprite for offline use..."
  svg_sprite_path = File.join(offline_dir, 'assets', 'css', 'cb-icons.svg')
  if File.exist?(svg_sprite_path)
    sprite_svg = File.read(svg_sprite_path, encoding: 'utf-8')
    # strip XML declaration — not valid inside HTML documents
    sprite_svg = sprite_svg.sub(/\A<\?xml[^>]*\?>\s*/, '')
    # mark the injected sprite as hidden; it is a symbol library, not visible content
    inline_sprite = sprite_svg.sub(/<svg\b/, '<svg style="display:none" aria-hidden="true"')

    inlined = 0
    Dir.glob(File.join(offline_dir, '**', '*.html')).each do |filepath|
      content = offline_read(filepath)
      next if content.nil?
      new_content = content.dup

      # inject the sprite right after the opening <body> tag so symbols are available
      # to all <use> references in the document (and dynamically-created ones via JS)
      new_content = new_content.sub(/(<body\b[^>]*>)/, "\\1\n#{inline_sprite}")

      # rewrite all href references that point to the external sprite file to use
      # fragment-only hrefs (e.g. href="#icon-image"), which reference the now-inlined symbols.
      # the path prefix varies by directory depth after link rewriting, so we match
      # any characters up to "cb-icons.svg#" rather than a fixed path.
      new_content = new_content.gsub(/(href=["'])[^"']*cb-icons\.svg#/, '\1#')

      if new_content != content
        File.write(filepath, new_content, encoding: 'utf-8')
        inlined += 1
      end
    end
    puts "  #{inlined} file(s) updated with inline SVG sprite."
  else
    puts "  Warning: '#{svg_sprite_path}' not found, skipping SVG icon inlining."
  end

  puts "\nDone! Offline site created in '#{offline_dir}'."
  puts "Open '#{File.join(offline_dir, 'index.html')}' in a browser to browse the collection."
end

