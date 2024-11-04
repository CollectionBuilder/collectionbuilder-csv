module Jekyll
    module RegexMatch
        def regex_match(input_str, regex_str)
          begin
            regex = Regexp.new(regex_str)
            input_str.scan(regex).flatten
          rescue RegexpError => e
            # Handle invalid regex pattern
            return []
          end
        end
  
        def regex_match_once(input_str, regex_str)
          begin
            regex = Regexp.new(regex_str)
            match = input_str.match(regex)
            return match.nil? ? nil : match[0]
          rescue RegexpError => e
            # Handle invalid regex pattern
            return nil
          end
        end

        def filter_items_by_year(items, year, regex_pattern = '[-]?[\dXu]{4,}')
          raise ArgumentError, 'Regex pattern too complex' if regex_pattern.length > 50
          return [] unless items.is_a?(Array) && !year.nil?
          begin

          # Clear cache if it grows too large
          if defined?(@cache_size) && @cache_size > 1000
            items.each { |item| item.delete('cached_dates') }
            @cache_size = 0
          end

          regex = Regexp.new(regex_pattern)  
          items.select do |item|
            next false unless item.is_a?(Hash) && item['date'].is_a?(String)

            # Track cache size
            @cache_size ||= 0
            @cache_size += 1 unless item['cached_dates']

            dates = item['cached_dates'] ||= item['date'].scan(regex).map(&:to_s) 
            dates.include?(year)  
          end
          rescue RegexpError => e
            Jekyll.logger.error "RegexMatch:", "Invalid regex pattern: #{e.message}"
            # Handle invalid regex pattern
            []
          end
        end

    end
  end
  
  Liquid::Template.register_filter(Jekyll::RegexMatch)