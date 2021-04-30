# use like {{ myarray | array_count_uniq }}
# where myarray is a liquid array 
# returns an array of the unique values + counts
# evan will 2018 for CollectionBuilder project
module Jekyll
  module ArrayCountUniq
    def array_count_uniq(input)
      clean = input.compact.collect(&:strip).reject(&:empty?)
      clean.uniq.map { |x| [x, clean.count(x)] }.sort_by {|k, v| -v}.to_h
    end
  end
end
  
Liquid::Template.register_filter(Jekyll::ArrayCountUniq)