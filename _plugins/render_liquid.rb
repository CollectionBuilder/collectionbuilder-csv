# frozen_string_literal: true

#########
#
# CollectionBuilder Liquidify
#
# Jekyll plugin that adds a filter to evaluate a string variable and render it's Liquid
# Named after markdownify, jsonify, and slugify filters
# 
# Use like {{ page.example | liquidify }} 
module Jekyll
  module RenderLiquid
    def liquidify(content)
      Liquid::Template.parse(content).render(@context)
    end
  end
end

Liquid::Template.register_filter(Jekyll::RenderLiquid)
