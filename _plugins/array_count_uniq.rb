########
#
# Array Count Plugin v0.2-csv
#
#   Adds Liquid filters to provide the unique values and their count:
#
#   1. array_count_uniq - takes a Liquid array and returns an array of the unique values with their counts. 
#     Use like {{ myarray | array_count_uniq }}
#
#   2. field_count_uniq - takes a Liquid hash and one or more specific fields in the hash, returns an array of the unique values, their field, and their counts. 
#   Each value in the field will be treated as multivalued split by semicolon. 
#   Whitespace is stripped and empty values removed.
#   Each value in the returned array will have the term, count, and field that it came from.
#      Use like: {% assign uniques = myhash | field_count_uniq: 'example' %}
#      For multiple fields, separate using a semicolon.
#      E.g. {% assign uniques = myhash | field_count_uniq: 'example;subjects' %}
#      Access the values like:
#      {% t in uniques %}Term: {{ t[0] }}, Count: {{ t[1] }}, Field: {{ t[2] }}{% endif %}
#
#   3. remove_stopwords - takes a Liquid hash or array and a semicolon separated list of stop words, returns the array with items matching the stop words removed.
#   Optionally, the index number of the field in a hash to use for filtering the array can be given as the second option to the filter (by default it will use index 0).
#   Stopword values are stripped of extra white space and compared non-case sensitive.
#       Use like: {% assign uniques = myhash | field_count_uniq: 'example' | remove_stopwords: 'common word; dogs; cats' %}
#       Or, {{ myarray | remove_stopwords: 'example' }}
#       Or, {{ myhash | remove_stopwords: 'example', 2 }}
#
#   4. strip_each - takes a Liquid array, returns the array with white space stripped and normalized for each value.
#       Use like: {% assign clean_values = mylist | split: ';' | strip_each %}
#
# evanwill 2026 for CollectionBuilder project
#
#######
module Liquid
  module ArrayCountUniq
    
    def array_count_uniq(input)
      clean = input.compact.collect(&:strip).reject(&:empty?)
      clean.uniq.map { |x| [x, clean.count(x)] }.sort_by {|k, v| -v}.to_h
    end

    def field_count_uniq(input, fields)
      field_list = fields.to_s.split(';').map(&:strip).reject(&:empty?)
      counts = {}
      input.each do |record|
        field_list.each do |field|
          value = record[field]
          next if value.nil? || value.to_s.strip.empty?
          value.to_s.downcase.split(';').map(&:strip).reject(&:empty?).each do |term|
            key = [term, field]
            counts[key] = (counts[key] || 0) + 1
          end
        end
      end
      counts.map { |k, v| [k[0], v, k[1]] }.sort_by { |item| item[0] }
    end

    def remove_stopwords(input, stopwords, index = 0)
      stops = stopwords.to_s.split(';').map { |s| s.strip.downcase }.reject(&:empty?)
      input.reject do |item|
        value = item.is_a?(Array) ? item[index] : item
        stops.include?(value.to_s.strip.downcase)
      end
    end

    def strip_each(input)
      input.map { |item| item.to_s.strip.gsub(/\s+/, ' ') }
    end

  end
end
  
Liquid::Template.register_filter(Liquid::ArrayCountUniq)