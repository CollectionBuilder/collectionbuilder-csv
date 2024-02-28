module Jekyll
    module SortEDTF
        def sort_edtf(array_of_strings)
            sorted = array_of_strings.map { |str| str.gsub('X', '0') }
            sorted.sort_by { |str| str[/\d+/].to_i }
        end
    end
end
  
Liquid::Template.register_filter(Jekyll::SortEDTF)