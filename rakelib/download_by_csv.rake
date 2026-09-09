# frozen_string_literal: true

###############################################################################
# TASK: download_by_csv
#
# read csv, download objects using the Ruby standard library
###############################################################################

require 'net/http'
require 'uri'
require 'openssl'
require 'time'

# Helpers for the download_by_csv task.
# Kept in a module since all files in "rakelib" share one namespace.
module CBDownload
  # network settings
  MAX_REDIRECTS = 10
  MAX_ATTEMPTS = 3
  MAX_RETRY_WAIT = 120
  OPEN_TIMEOUT = 15
  READ_TIMEOUT = 60
  WRITE_TIMEOUT = 60
  CHUNK_LOG_SECONDS = 0.5
  # many library servers reject the default ruby user agent
  USER_AGENT = 'Mozilla/5.0 (compatible; CollectionBuilder download_by_csv)'
  # response codes worth trying again
  RETRY_STATUS = [408, 425, 429, 500, 502, 503, 504].freeze
  # network errors worth trying again
  RETRY_ERRORS = [
    Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNRESET, Errno::ECONNABORTED,
    Errno::EPIPE, Errno::ETIMEDOUT, Errno::EHOSTUNREACH, Errno::ECONNREFUSED,
    Errno::ENETUNREACH, EOFError, SocketError, OpenSSL::SSL::SSLError
  ].freeze
  # guess an extension when neither the url nor the headers give a filename
  EXTENSIONS = {
    'image/jpeg' => '.jpg', 'image/png' => '.png', 'image/tiff' => '.tif',
    'image/gif' => '.gif', 'image/webp' => '.webp', 'image/svg+xml' => '.svg',
    'application/pdf' => '.pdf', 'audio/mpeg' => '.mp3', 'audio/wav' => '.wav',
    'audio/x-wav' => '.wav', 'audio/ogg' => '.ogg', 'video/mp4' => '.mp4',
    'video/quicktime' => '.mov', 'video/webm' => '.webm', 'text/plain' => '.txt',
    'text/html' => '.html', 'text/xml' => '.xml', 'application/xml' => '.xml',
    'application/json' => '.json', 'application/zip' => '.zip'
  }.freeze

  class Error < StandardError; end

  # an http response that is not a success or a redirect
  class HTTPError < Error
    attr_reader :code, :retry_after

    def initialize(response)
      @code = response.code.to_i
      @retry_after = CBDownload.parse_retry_after(response['retry-after'])
      super("server returned #{response.code} #{response.message}")
    end
  end

  @last_request_at = nil

  #############################################################################
  # download one row
  #############################################################################

  # returns [status, path] where status is :downloaded or :skipped
  def self.fetch_to_file(url, output_dir, rename, index, total, delay)
    puts "[#{index}/#{total}] #{url}"

    # when the new name is known up front, skip before touching the network
    if rename
      dest = File.join(output_dir, sanitize_filename(rename, "item_#{index}"))
      if File.exist?(dest)
        puts "  '#{dest}' already exists, skipping!"
        return [:skipped, dest]
      end
    end

    throttle(delay)

    with_retries do
      with_response(url) do |response, final_uri|
        name = rename || filename_from(response, final_uri, index)
        dest = File.join(output_dir, sanitize_filename(name, "item_#{index}"))
        if File.exist?(dest)
          puts "  '#{dest}' already exists, skipping!"
          next [:skipped, dest]
        end

        warn_if_html(response, dest)
        written = write_stream(response, dest)
        puts "  saved '#{dest}' (#{human_size(written)})"
        [:downloaded, dest]
      end
    end
  end

  #############################################################################
  # http
  #############################################################################

  # request url, following redirects, and yield the successful response
  def self.with_response(url)
    uri = parse_uri(url)
    cookies = {}
    result = nil

    (MAX_REDIRECTS + 1).times do
      unless %w[http https].include?(uri.scheme.to_s)
        raise Error, "unsupported url scheme '#{uri.scheme}'"
      end

      redirect = nil
      @last_request_at = Time.now

      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https',
                      open_timeout: OPEN_TIMEOUT,
                      read_timeout: READ_TIMEOUT,
                      write_timeout: WRITE_TIMEOUT,
                      max_retries: 0) do |http|
        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = USER_AGENT
        request['Accept'] = '*/*'
        # ask for the bytes as they are so streamed binaries are never gzipped
        request['Accept-Encoding'] = 'identity'
        request['Cookie'] = cookie_header(cookies) unless cookies.empty?
        if uri.user
          request.basic_auth(percent_decode(uri.user), percent_decode(uri.password.to_s))
        end

        http.request(request) do |response|
          collect_cookies(cookies, response)
          if response.is_a?(Net::HTTPRedirection)
            redirect = next_location(uri, response)
          elsif response.is_a?(Net::HTTPSuccess)
            result = yield(response, uri)
          else
            raise HTTPError, response
          end
        end
      end

      return result if redirect.nil?

      uri = redirect
    end

    raise Error, "too many redirects (more than #{MAX_REDIRECTS})"
  end

  # run a request, trying again on temporary failures
  def self.with_retries
    attempt = 0
    begin
      attempt += 1
      yield
    rescue HTTPError => e
      raise if !RETRY_STATUS.include?(e.code) || attempt >= MAX_ATTEMPTS

      wait = e.retry_after || backoff(attempt)
      raise Error, "#{e.message} (retry-after #{wait}s exceeds max wait of #{MAX_RETRY_WAIT}s)" if wait > MAX_RETRY_WAIT

      report_retry(e.message, wait, attempt)
      sleep wait
      retry
    rescue *RETRY_ERRORS => e
      raise if attempt >= MAX_ATTEMPTS

      wait = backoff(attempt)
      report_retry("#{e.class}: #{e.message}", wait, attempt)
      sleep wait
      retry
    end
  end

  def self.report_retry(message, wait, attempt)
    puts "  #{message}, trying again in #{wait.round}s (attempt #{attempt + 1} of #{MAX_ATTEMPTS})"
  end

  def self.backoff(attempt)
    2**attempt
  end

  # resolve the next url in a redirect chain, handling relative locations
  def self.next_location(uri, response)
    location = response['location'].to_s.strip
    raise Error, "redirect (#{response.code}) with no location header" if location.empty?

    target = uri.merge(parse_uri(location))
    if uri.scheme == 'https' && target.scheme == 'http'
      puts "  WARNING: redirect downgrades from https to http"
    end
    puts "  redirected to #{target}"
    target
  end

  # keep session cookies through the whole chain, some repositories set one
  # on the permalink host and expect it back on the object host
  def self.collect_cookies(cookies, response)
    fields = response.get_fields('set-cookie')
    return if fields.nil?

    fields.each do |raw|
      name, value = raw.split(';', 2).first.to_s.strip.split('=', 2)
      cookies[name] = value if name && !name.empty? && value
    end
  end

  def self.cookie_header(cookies)
    cookies.map { |name, value| "#{name}=#{value}" }.join('; ')
  end

  def self.parse_retry_after(value)
    value = value.to_s.strip
    return nil if value.empty?
    return value.to_i if value.match?(/\A\d+\z/)

    seconds = (Time.httpdate(value) - Time.now).ceil
    seconds.positive? ? seconds : nil
  rescue ArgumentError
    nil
  end

  # wait so that requests are at least delay seconds apart
  def self.throttle(delay)
    return if delay <= 0 || @last_request_at.nil?

    elapsed = Time.now - @last_request_at
    sleep(delay - elapsed) if elapsed < delay
  end

  #############################################################################
  # urls and filenames
  #############################################################################

  def self.parse_uri(url)
    URI.parse(url.to_s.strip)
  rescue URI::InvalidURIError
    # some servers send locations containing spaces or other raw characters
    URI.parse(escape_unsafe(url.to_s.strip))
  end

  def self.escape_unsafe(url)
    url.gsub(%r{[^A-Za-z0-9\-._~:/?\#\[\]@!$&'()*+,;=%]}) do |char|
      char.bytes.map { |byte| format('%%%02X', byte) }.join
    end
  end

  def self.percent_decode(value)
    decoded = value.to_s.gsub(/%[0-9A-Fa-f]{2}/) { |match| match[1, 2].hex.chr }
    decoded = decoded.dup.force_encoding(Encoding::UTF_8)
    decoded.valid_encoding? ? decoded : value.to_s
  end

  # work out a filename from the headers, then the final url, then the row
  def self.filename_from(response, uri, index)
    extension = EXTENSIONS.fetch(content_type(response), '')
    name = filename_from_disposition(response['content-disposition'])
    name = percent_decode(File.basename(uri.path.to_s)) if name.nil? || name.empty?
    return "item_#{index}#{extension}" if name.nil? || name.empty?

    # urls like "/download" or "/objects/1234" resolve to a name with no
    # extension, so take one from the content type
    name += extension if File.extname(name).empty?
    name
  end

  def self.filename_from_disposition(header)
    header = header.to_s
    return nil if header.empty?

    # rfc 5987 form, filename*=UTF-8''name.jpg
    match = header.match(/filename\*\s*=\s*[^']*'[^']*'([^;]+)/i)
    return percent_decode(match[1].strip) if match

    match = header.match(/filename\s*=\s*"([^"]*)"/i) || header.match(/filename\s*=\s*([^;]+)/i)
    match ? match[1].strip : nil
  end

  # never let a header or url write outside of the output directory
  def self.sanitize_filename(name, fallback)
    name = name.to_s.split(/[?#]/).first.to_s
    name = File.basename(name.tr('\\', '/')).strip
    name = name.gsub(/[\x00-\x1f<>:"|*?]/, '_')
    name = '' if ['.', '..'].include?(name)
    return fallback if name.empty?

    if name.length > 150
      extension = File.extname(name)[0, 20].to_s
      name = File.basename(name, File.extname(name))[0, 150 - extension.length] + extension
    end
    name
  end

  def self.content_type(response)
    response['content-type'].to_s.split(';').first.to_s.strip.downcase
  end

  def self.warn_if_html(response, dest)
    return unless ['text/html', 'application/xhtml+xml'].include?(content_type(response))
    return if ['.html', '.htm', '.xhtml'].include?(File.extname(dest).downcase)

    puts '  WARNING: the server returned a web page, this may be an error or login page'
  end

  #############################################################################
  # writing
  #############################################################################

  # stream to a part file so a failed download never leaves a broken object
  def self.write_stream(response, dest)
    part = "#{dest}.part"
    expected = response['content-length'].to_i
    written = 0
    shown = false
    logged_at = Time.now

    File.open(part, 'wb') do |file|
      response.read_body do |chunk|
        file.write(chunk)
        written += chunk.bytesize
        next unless expected.zero? || expected > 1_000_000
        next unless Time.now - logged_at > CHUNK_LOG_SECONDS

        print_progress(written, expected)
        shown = true
        logged_at = Time.now
      end
    end
    clear_progress if shown

    if expected.positive? && written != expected
      raise Error, "incomplete download, expected #{expected} bytes but got #{written}"
    end

    File.rename(part, dest)
    written
  rescue StandardError, Interrupt
    File.delete(part) if File.exist?(part)
    raise
  end

  def self.print_progress(written, expected)
    if expected.positive?
      percent = (written * 100.0 / expected).round
      print "\r  #{percent}% of #{human_size(expected)}"
    else
      print "\r  #{human_size(written)}"
    end
    $stdout.flush
  end

  def self.clear_progress
    print "\r#{' ' * 40}\r"
    $stdout.flush
  end

  def self.human_size(bytes)
    return "#{bytes} B" if bytes < 1024
    return "#{(bytes / 1024.0).round(1)} KB" if bytes < 1_048_576

    "#{(bytes / 1_048_576.0).round(1)} MB"
  end

  # record failures so they can be fed back into the task as a csv
  def self.write_error_csv(failures, output_dir, link_column, rename_column)
    path = File.join(output_dir, 'download_errors.csv')
    CSV.open(path, 'wb') do |csv|
      csv << [link_column, rename_column, 'error']
      failures.each { |failure| csv << [failure[:url], failure[:rename], failure[:error]] }
    end
    path
  end
end

desc "download objects and rename using csv"
task :download_by_csv, [:csv_file, :download_link, :download_rename, :output_dir, :delay] do |_t, args|
  # set default arguments
  args.with_defaults(
    csv_file: 'download.csv',
    download_link: 'url',
    download_rename: 'filename_new',
    output_dir: 'download/',
    delay: '1'
  )

  # rake arguments always arrive as strings
  delay = args.delay.to_f
  delay = 0.0 if delay.negative?

  # check for csv file
  unless File.exist?(args.csv_file)
    puts "CSV file does not exist! No files downloaded and exiting."
    next
  end

  # read csv file
  csv_text = File.read(args.csv_file, :encoding => 'utf-8')
  csv_contents = CSV.parse(csv_text, headers: true)

  # check for the download url column
  unless csv_contents.headers.include?(args.download_link)
    puts "CSV does not have a '#{args.download_link}' column! No files downloaded and exiting."
    next
  end
  has_rename = csv_contents.headers.include?(args.download_rename)

  # Ensure that the output directory exists.
  FileUtils.mkdir_p(args.output_dir) unless Dir.exist?(args.output_dir)

  total = csv_contents.size
  downloaded = 0
  skipped = 0
  failures = []

  puts "downloading #{total} rows from '#{args.csv_file}' into '#{args.output_dir}'"
  puts "waiting #{delay}s between requests" if delay.positive?

  # iterate on csv rows
  csv_contents.each_with_index do |item, index|
    # check for download url
    url = item[args.download_link].to_s.strip
    if url.empty?
      puts "[#{index + 1}/#{total}] no download url!"
      next
    end

    # check for rename
    rename = has_rename ? item[args.download_rename].to_s.strip : ''
    rename = nil if rename.empty?

    begin
      status, = CBDownload.fetch_to_file(url, args.output_dir, rename, index + 1, total, delay)
      status == :skipped ? skipped += 1 : downloaded += 1
    rescue StandardError => e
      puts "  ERROR: #{e.message}"
      failures << { url: url, rename: rename, error: e.message }
    end
  end

  puts "done downloading. #{downloaded} downloaded, #{skipped} skipped, #{failures.length} failed."

  unless failures.empty?
    error_csv = CBDownload.write_error_csv(failures, args.output_dir, args.download_link, args.download_rename)
    puts "failed downloads written to '#{error_csv}'"
  end
end
