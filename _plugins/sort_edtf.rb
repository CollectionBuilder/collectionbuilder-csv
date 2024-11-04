module Jekyll
  module SortEDTF
    def sort_edtf(array_of_strings)
      non_empty_dates = array_of_strings.reject { |str| str.strip.empty? }

      processed_dates = non_empty_dates.map do |str|
      normalized_date_str = replace_x_with_parsable_0(str)
      date_as_integer = normalize_to_integer(normalized_date_str)
      display_format = create_display_format(str)

      { numeric: date_as_integer, original: str, display_format: display_format }
      end

      sorted_dates = processed_dates.sort_by { |date| -date[:numeric] }
      sorted_dates.map { |date| "#{date[:display_format]}:#{date[:original]}:#{date[:numeric]}" }
    end

    private

    def replace_x_with_parsable_0(str)
      str.gsub(/[Xu]/, '0')
    end

    def normalize_to_integer(year_str)
      numeric_str = if year_str.start_with?('-')
                        year_str.sub(/^-0+/, '-')
                       else
                        year_str.sub(/^0+(?=\d)/, '')
                       end
    
      if numeric_str.match?(/^-?\d+$/)
        numeric_str.to_i
      else
        raise ArgumentError, "Invalid year format: #{year_str}"
      end
    end

    def create_display_format(str)
      if str.start_with?('-')
        "#{str[1..-1].sub(/^0+/, '')} v. u. Z."
      else
        str.sub(/^0+(?=\d)/, '')
      end
    end


  end
end
  
Liquid::Template.register_filter(Jekyll::SortEDTF)