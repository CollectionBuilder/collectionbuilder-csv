# Unit tests for the link rewriting helpers in rakelib/build_offline.rake
#
# run from the project root:  ruby rakelib/test/offline_rewrite_test.rb
#
# builds a small fake site directory so that the "does this path point into the site"
# check used by the fallback rewrite behaves as it does during a real build.

require 'minitest/autorun'
require 'rake'
require 'tmpdir'
require 'fileutils'
include Rake::DSL
load File.expand_path('../build_offline.rake', __dir__)

class OfflineRewriteTest < Minitest::Test
  S = OFFLINE_SENTINEL

  def setup
    @dir = Dir.mktmpdir('offline_test')
    %w[index.html browse.html search/index.html items/demo.html objects/x.pdf
       objects/thumbs/demo_th.jpg assets/css/cb.css assets/js/app.js].each do |f|
      FileUtils.mkdir_p(File.dirname(File.join(@dir, f)))
      File.write(File.join(@dir, f), '')
    end
    @top = Dir.children(@dir).to_set
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  # rewrite at depth 1 (e.g. items/demo.html) as an html file unless given
  def rewrite(input, depth: 1, url_map: {}, type: :html)
    offline_rewrite_links(input.dup, depth, url_map, @top, type: type)
  end

  # --- sentinel in complete attribute values (step 2)

  def test_root_link_becomes_index
    assert_equal 'href="../index.html"', rewrite(%(href="#{S}/"))
    assert_equal 'href="index.html"', rewrite(%(href="#{S}/"), depth: 0)
  end

  def test_root_anchor_and_query_keep_tail
    assert_equal 'href="../index.html#top"', rewrite(%(href="#{S}/#top"))
    assert_equal 'href="../index.html?q=1"', rewrite(%(href="#{S}/?q=1"))
  end

  def test_directory_permalink_gets_index
    assert_equal 'href="../search/index.html"', rewrite(%(href="#{S}/search/"))
    assert_equal 'href="../search/index.html#x"', rewrite(%(href="#{S}/search/#x"))
    assert_equal "href='../search/index.html'", rewrite(%(href='#{S}/search/'))
  end

  def test_file_paths_and_query_strings
    assert_equal 'href="../browse.html?x=1"', rewrite(%(href="#{S}/browse.html?x=1"))
    assert_equal 'src="objects/thumbs/demo_th.jpg"', rewrite(%(src="#{S}/objects/thumbs/demo_th.jpg"), depth: 0)
    assert_equal 'src="../../assets/css/cb.css"', rewrite(%(src="#{S}/assets/css/cb.css"), depth: 2)
  end

  def test_object_data_and_video_poster
    assert_equal 'data="../objects/x.pdf"', rewrite(%(data="#{S}/objects/x.pdf"))
    assert_equal 'poster="../objects/thumbs/demo_th.jpg"', rewrite(%(poster="#{S}/objects/thumbs/demo_th.jpg"))
  end

  def test_absolute_url_output_with_host
    assert_equal 'content="../items/demo.html"', rewrite(%(content="https://example.org#{S}/items/demo.html"))
    # quoted strings outside attributes get the plain prefix (they may be concatenation prefixes)
    assert_equal '"url":"../"', rewrite(%("url":"https://example.org#{S}/"))
  end

  def test_attribute_value_with_apostrophe
    assert_equal %q{href="../browse.html#Hell's%20Half%20Acre"}, rewrite(%(href="#{S}/browse.html#Hell's%20Half%20Acre"))
  end

  def test_js_built_attribute_keeps_prefix_slash
    # lunr-js: href="/items/' + store[ref].id + '"
    assert_equal %q{'<a href="../items/' + store[ref].id + '">'}, rewrite(%('<a href="#{S}/items/' + store[ref].id + '">'))
    # concatenation with the same quote type
    assert_equal %q{href="../items/" + id + ".html"}, rewrite(%(href="#{S}/items/" + id + ".html"))
    # cloud-js: href="/browse.html#' + field + ':' + value + '"
    input = %('<a href="#{S}/browse.html#' + array[i][2] + ':' + encodeURIComponent(array[i][0]) + '">')
    assert_equal %q{'<a href="../browse.html#' + array[i][2] + ':' + encodeURIComponent(array[i][0]) + '">'}, rewrite(input)
  end

  # --- sentinel elsewhere (step 3)

  def test_js_string_prefix
    assert_equal "'../items/' + id", rewrite(%('#{S}/items/' + id))
    assert_equal "'' + data", rewrite(%('#{S}/' + data), depth: 0)
    assert_equal "'../' + data", rewrite(%('#{S}/' + data))
  end

  def test_inline_json_and_template_literal
    assert_equal '"img": "../objects/thumbs/demo_th.jpg"', rewrite(%("img": "#{S}/objects/thumbs/demo_th.jpg"))
    input = %(`#{S}/items/${ obj.parent ? obj.parent + ".html#" + obj.id : obj.id + ".html" }`)
    assert_equal '`../items/${ obj.parent ? obj.parent + ".html#" + obj.id : obj.id + ".html" }`', rewrite(input)
  end

  def test_bare_sentinel
    assert_equal "'..' + '/x'", rewrite(%('#{S}' + '/x'))
    assert_equal "'' + '/x'", rewrite(%('#{S}' + '/x'), depth: 0)
  end

  def test_css_resolves_relative_to_file
    assert_equal 'url(../../assets/x.png)', rewrite(%(url(#{S}/assets/x.png)), depth: 2, type: :css)
  end

  def test_js_and_data_files_get_root_relative_paths
    assert_equal '"/objects/x.pdf"', rewrite(%("#{S}/objects/x.pdf"), depth: 2, type: :js)
    assert_equal '"/items/demo.html"', rewrite(%("https://example.org#{S}/items/demo.html"), depth: 2, type: :json)
    assert_equal 'objects/x.pdf,/browse.html', rewrite(%(objects/x.pdf,#{S}/browse.html), depth: 2, type: :csv)
  end

  # --- fallback for hardcoded root-relative attribute paths (step 4)

  def test_hardcoded_attribute_path
    assert_equal 'href="../browse.html"', rewrite('href="/browse.html"')
    assert_equal 'href="../index.html"', rewrite('href="/"')
    assert_equal 'href="../search/index.html"', rewrite('href="/search/"')
    assert_equal 'src="../objects/thumbs/demo_th.jpg"', rewrite('src="/objects/thumbs/demo_th.jpg"')
  end

  def test_hardcoded_unknown_path_untouched
    assert_equal 'href="/nowhere/x.html"', rewrite('href="/nowhere/x.html"')
  end

  def test_meta_description_starting_with_slash_untouched
    input = 'content="/slash-led description"'
    assert_equal input, rewrite(input)
  end

  def test_protocol_relative_untouched
    assert_equal 'src="//cdn.x/y.js"', rewrite('src="//cdn.x/y.js"')
  end

  def test_plain_js_strings_untouched
    assert_equal 's.split("/")', rewrite('s.split("/")')
    assert_equal 'var x = "/ not a path";', rewrite('var x = "/ not a path";')
    assert_equal '"/objects/x.pdf"', rewrite('"/objects/x.pdf"')  # no sentinel, not an attribute
    assert_equal '`/${dir}/x.html`', rewrite('`/${dir}/x.html`')
  end

  def test_same_host_external_asset_untouched
    input = 'src="https://example.org/media/logo.png"'
    assert_equal input, rewrite(input)
  end

  def test_fallback_disabled_without_top_level
    assert_equal 'href="/browse.html"', offline_rewrite_links('href="/browse.html"', 1, {}, nil)
  end

  # --- downloaded media (step 1)

  def test_url_map_replacement
    map = { 'https://cdn.example.com/a/b/pic.jpg' => '/objects/thumbs/demo_th.jpg' }
    assert_equal 'src="../objects/thumbs/demo_th.jpg"', rewrite('src="https://cdn.example.com/a/b/pic.jpg"', url_map: map)
  end

  def test_url_map_prefix_collision
    # the shorter URL is a prefix of the longer one; longest must be substituted first
    map = {
      'https://x.org/a.jpg'            => '/objects/a.jpg',
      'https://x.org/a.jpg?size=large' => '/objects/b.jpg'
    }
    input = %q{<img src="https://x.org/a.jpg?size=large"><img src="https://x.org/a.jpg">}
    assert_equal %q{<img src="../objects/b.jpg"><img src="../objects/a.jpg">}, rewrite(input, url_map: map)
  end

  def test_url_map_uses_root_relative_paths_in_data_files
    # a data export must not mix relative and root-relative styles: both the downloaded media
    # and the sentinel paths come out root-relative
    map = { 'https://cdn.example.com/pic.jpg' => '/objects/thumbs/demo_th.jpg' }
    input = %(["https://cdn.example.com/pic.jpg","#{S}/objects/x.pdf"])
    assert_equal '["/objects/thumbs/demo_th.jpg","/objects/x.pdf"]', rewrite(input, depth: 2, url_map: map, type: :json)
  end

  # --- helpers

  def test_offline_dest_filename
    assert_equal 'demo_001_sm.jpg', offline_dest_filename('demo_001', 'https://x.org/a/default.jpg?x=1', '_sm')
    assert_equal 'demo_002.pdf', offline_dest_filename('demo_002', 'https://x.org/a/file.PDF', '')
    assert_match(/\Adefault_[0-9a-f]{8}_th\.jpg\z/, offline_dest_filename('', 'https://x.org/a/default.jpg', '_th'))
  end

  def test_offline_downloadable
    assert offline_downloadable?('https://img.youtube.com/vi/abc/hqdefault.jpg', OFFLINE_MEDIA_EXTENSIONS)
    refute offline_downloadable?('https://www.youtube.com/watch?v=abc', OFFLINE_MEDIA_EXTENSIONS)
    refute offline_downloadable?('https://x.org/v.mp4', OFFLINE_MEDIA_EXTENSIONS)
    assert offline_downloadable?('https://x.org/v.mp4', OFFLINE_MEDIA_EXTENSIONS + OFFLINE_VIDEO_EXTENSIONS)
    refute offline_downloadable?('http://bad url/x.jpg', OFFLINE_MEDIA_EXTENSIONS)
  end

  def test_offline_read_rejects_invalid_utf8
    path = File.join(@dir, 'bad.html')
    File.binwrite(path, "<p>\xFF\xFE</p>")
    assert_nil offline_read(path)
    assert_equal '', offline_read(File.join(@dir, 'index.html'))
  end
end
