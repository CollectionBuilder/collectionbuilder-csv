###############################################################################
# TASK: build_offline
#
# build a CollectionBuilder site and replace links for offline use
#
# generates the Jekyll site, downloads external media (images, pdfs), 
# and rewrites all internal links so the site works from the local filesystem without a server.
#
# options (passed as rake arguments, e.g. rake build_offline[true,offline_site]):
#   download_external - download external media linked in metadata, true/false (default: true)
#   output_dir        - directory name for the offline output (default: "offline_site")
#
# see docs/rake_tasks/build_offline.md for full documentation
###############################################################################

require 'open-uri'
require 'pathname'
require 'uri'
require 'yaml'

# file types to download for offline use (images and audio; streaming video is skipped)
OFFLINE_MEDIA_EXTENSIONS = %w[.jpg .jpeg .png .gif .tif .tiff .pdf .mp3 .wav .ogg .m4a].freeze

# streaming/video platforms to skip when downloading external media
OFFLINE_SKIP_DOMAINS = %w[youtube.com youtu.be vimeo.com soundcloud.com].freeze

# check if a URL is from a platform that should be skipped for downloading
def offline_skip_url?(url)
  OFFLINE_SKIP_DOMAINS.any? { |domain| url.include?(domain) }
end

# check whether the URL points to a file type eligible for offline download
def offline_downloadable?(url)
  ext = File.extname(URI.parse(url).path).downcase
  OFFLINE_MEDIA_EXTENSIONS.include?(ext)
rescue URI::InvalidURIError
  false
end

# download a file from url and save to dest_path; returns true on success
def offline_download(url, dest_path)
  puts "Downloading: #{url}"
  URI.open(url, 'rb') do |remote|
    IO.copy_stream(remote, dest_path)
  end
  puts "  -> #{dest_path}"
  true
rescue OpenURI::HTTPError, SocketError, Errno::ECONNREFUSED, RuntimeError => e
  puts "  -> download failed: #{e.message}"
  FileUtils.rm_f(dest_path)
  false
end

# rewrite all internal links in a file's content for local filesystem use.
# depth    - number of directory levels below the offline root (0 = root-level files)
# site_url - absolute URL prefix from Jekyll config (url + baseurl), used in data files
# url_map  - hash of { external_url => root_relative_local_path } for downloaded media
def offline_rewrite_links(content, depth, site_url, url_map)
  prefix = '../' * depth

  # 1. replace downloaded external media URLs with relative local paths
  url_map.each do |external_url, local_path|
    content = content.gsub(external_url, "#{prefix}#{local_path.delete_prefix('/')}")
  end

  # 2. replace absolute site URLs (Jekyll url + baseurl, or localhost:4000 when url is unset)
  #    these appear in generated data files and occasionally in HTML meta tags
  unless site_url.empty?
    escaped = Regexp.escape(site_url)
    content = content.gsub(%r{#{escaped}(/[^\s"'<>()\[\]]+)}) do
      "#{prefix}#{$1.delete_prefix('/')}"
    end
    # bare site root URL with no following path
    content = content.gsub(%r{#{escaped}/?(?=[\s"'<>()\[\]])}) do
      "#{prefix}index.html"
    end
  end

  # 3. rewrite root-relative paths in HTML attribute values
  #    covers href, src, action, content (meta), xlink:href (SVG), data-src (lazy-load)
  #    negative lookahead (?!\/) prevents rewriting protocol-relative URLs (//)
  content = content.gsub(/((?:href|src|action|content|xlink:href|data-src)=["'])(\/(?!\/)[^"']*)/) do
    local = $2.delete_prefix('/')
    local = 'index.html' if local.empty?
    "#{$1}#{prefix}#{local}"
  end

  # 4. rewrite root-relative paths in CSS url() references (inline styles and <style> blocks)
  content = content.gsub(/url\((['"]?)(\/(?!\/)[^'")\s]+)(['"]?)\)/) do
    "url(#{$1}#{prefix}#{$2.delete_prefix('/')}#{$3})"
  end

  # 5. rewrite root-relative paths in JS/JSON string literals (single and double quoted)
  #    handles inline data arrays like: "img": "/objects/thumbs/item_th.jpg"
  content = content.gsub(/(["'])(\/(?!\/)[^"'\r\n]+)(["'])/) do
    next "#{$1}#{$2}#{$3}" unless $1 == $3  # skip mismatched quotes (not a plain string)
    "#{$1}#{prefix}#{$2.delete_prefix('/')}#{$3}"
  end

  # 6. rewrite root-relative paths in JS template literals (backtick strings)
  #    handles dynamic hrefs like: `/items/${obj.id}.html`
  content = content.gsub(/`(\/(?!\/)[^`]+)`/) do
    "`#{prefix}#{$1.delete_prefix('/')}`"
  end

  content
end

desc 'Build jekyll site and rewrite links for offline use'
task :build_offline, [:download_external, :output_dir] do |_t, args|
  args.with_defaults(
    download_external: 'true',
    output_dir: 'offline_site'
  )

  download_external = args.download_external.to_s.strip.downcase != 'false'
  offline_dir = args.output_dir

  # build jekyll site with production environment
  ENV['JEKYLL_ENV'] = 'production'
  system('bundle', 'exec', 'jekyll', 'build')

  jekyll_site = '_site'
  abort "Jekyll build failed: '#{jekyll_site}' directory not found!" unless Dir.exist?(jekyll_site)

  # load site configuration for url, baseurl, and metadata filename
  config = YAML.load_file('_config.yml')
  baseurl = (config['baseurl'] || '').strip.chomp('/')
  site_url_val = (config['url'] || '').strip.chomp('/')
  # when url is blank, Jekyll uses http://localhost:4000 for absolute URLs in generated data files
  site_url = site_url_val.empty? ? "http://localhost:4000#{baseurl}" : "#{site_url_val}#{baseurl}"
  metadata_name = config['metadata']

  # recreate output directory for a clean build
  if Dir.exist?(offline_dir)
    puts "Removing existing '#{offline_dir}' for a clean build..."
    FileUtils.rm_rf(offline_dir)
  end
  FileUtils.mkdir_p(offline_dir)

  # copy built site contents into the offline directory (contents only, not _site subfolder)
  puts "Copying '#{jekyll_site}' to '#{offline_dir}'..."
  Dir.glob(File.join(jekyll_site, '{*,.*}')).each do |entry|
    next if ['.', '..'].include?(File.basename(entry))
    FileUtils.cp_r(entry, offline_dir)
  end

  # track { external_url => root_relative_local_path } for all downloaded files
  url_map = {}

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

        # metadata field => objects/ subdirectory for downloaded files
        media_field_dirs = {
          'object_location' => 'objects',
          'image_small'     => File.join('objects', 'small'),
          'image_thumb'     => File.join('objects', 'thumbs')
        }

        media_field_dirs.each do |field, subdir|
          next unless csv_data.headers.include?(field)

          dest_dir = File.join(offline_dir, subdir)
          FileUtils.mkdir_p(dest_dir)

          csv_data.each do |row|
            url = row[field]
            next if url.nil? || url.strip.empty?
            next unless url.start_with?('http')
            next if offline_skip_url?(url)
            next unless offline_downloadable?(url)
            next if url_map.key?(url)  # already queued from another field

            begin
              filename = File.basename(URI.parse(url).path)
            rescue URI::InvalidURIError
              puts "  Skipping invalid URL: #{url}"
              next
            end

            dest_path = File.join(dest_dir, filename)
            # root_relative_path uses forward slashes regardless of OS
            root_relative = "/#{[subdir.tr(File::SEPARATOR, '/'), filename].join('/')}"
            url_map[url] = root_relative

            offline_download(url, dest_path) unless File.exist?(dest_path)
          end
        end
      end
    end
  end

  # rewrite all links in html and js files for local filesystem use
  puts "Rewriting links for offline use..."
  updated = 0
  Dir.glob(File.join(offline_dir, '**', '*.{html,js}')).each do |filepath|
    rel = Pathname.new(filepath).relative_path_from(Pathname.new(offline_dir)).to_s
    depth = rel.count('/')
    content = File.read(filepath, encoding: 'utf-8', invalid: :replace, undef: :replace)
    new_content = offline_rewrite_links(content, depth, site_url, url_map)
    if new_content != content
      File.write(filepath, new_content, encoding: 'utf-8')
      updated += 1
    end
  end
  puts "  #{updated} file(s) updated."

  puts "\nDone! Offline site created in '#{offline_dir}'."
  puts "Open '#{File.join(offline_dir, 'index.html')}' in a browser to browse the collection."
end

