########
#
# Sort Numeric Jekyll Plugin v0.1-csv
#
#   Adds sort_numeric to Liquid filters to correctly sort an array of numbers 
#   (which Liquid does NOT current do). 
#   Useage:
#   - to sort an array {{ myarray | sort_numeric }}
#   - to sort a hash by a specific property {{ myarray | sort_numeric: "property" }}
#   where myarray is a liquid array,
#   returns the array sorted.
#
# hack plugin based on old PR to Liquid, https://github.com/Shopify/liquid/pull/1028
# that fixes documented issues, https://github.com/Shopify/liquid/issues/980
# updated to use current Liquid utilities and conventions following "sort"
# evanwill 2023 for CollectionBuilder project
#
#######
module Liquid
  module SortNumeric
    # Sort elements of the array as numbers
    # provide optional property with which to sort an array of hashes or drops
    def sort_numeric(input, property = nil)
      ary = InputIterator.new(input)
      
      return [] if ary.empty?

      if property.nil?
        ary.sort do |a, b|
          compare_numeric(a, b)
        end
      elsif ary.all? { |el| el.respond_to?(:[]) }
        begin
          ary.sort { |a, b| compare_numeric(a[property], b[property]) }
        rescue TypeError
          raise_property_error(property)
        end
      end
    end

    private 

    def compare_numeric(a, b)
      Utils.to_number(a) <=> Utils.to_number(b)
    end
    def raise_property_error(property)
      raise Liquid::ArgumentError, "cannot select the property '#{property}'"
    end

    class InputIterator
      include Enumerable

      def initialize(input)
        @input = if input.is_a?(Array)
          input.flatten
        elsif input.is_a?(Hash)
          [input]
        elsif input.is_a?(Enumerable)
          input
        else
          Array(input)
        end
      end

      def join(glue)
        to_a.join(glue.to_s)
      end

      def concat(args)
        to_a.concat(args)
      end

      def reverse
        reverse_each.to_a
      end

      def uniq(&block)
        to_a.uniq(&block)
      end

      def compact
        to_a.compact
      end

      def empty?
        @input.each { return false }
        true
      end

      def each
        @input.each do |e|
          yield(e.respond_to?(:to_liquid) ? e.to_liquid : e)
        end
      end
    end

  end
end
    
Liquid::Template.register_filter(Liquid::SortNumeric)