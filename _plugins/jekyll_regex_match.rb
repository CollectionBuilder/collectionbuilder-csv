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
    end
  end
  
  Liquid::Template.register_filter(Jekyll::RegexMatch)