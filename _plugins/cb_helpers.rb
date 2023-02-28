# frozen_string_literal: true

#########
#
# CollectionBuilder Helpers Generator, v1.1-csv
#
# Jekyll plugin to generate theme variables for the template.
# 
# Helper functions work with settings in "theme.yml" to add variables to site.data.
# This optimizes setting defaults and calculating some values,
# to avoid slow Liquid routines.
# (c) 2021 CollectionBuilder, evanwill, https://github.com/CollectionBuilder/
# Distributed under the conditions of the MIT license
#
#########

module CollectionBuilderHelperGenerator
  class Generator < Jekyll::Generator
    safe true

    def generate(site)

      #####
      #
      # Featured Item 
      # find featured image as configured in "theme.yml"
      # return new varible --> site.data.featured_item with .src, .alt, .link
      #
      #####

      # get featured image config from "theme.yml"
      featured_image = site.data['theme']['featured-image'] || "/assets/img/collectionbuilder-logo.png"
      
      if featured_image.include? "/"
        # if featured image is a link
        featured_item_src = featured_image
        featured_item_alt = site.config['title']
        featured_item_link = featured_item_src
      else
        # if featured image is an objectid
        # check configured metadata exists
        if site.data[site.config['metadata']]
          # find item in site metadata
          featured_record = site.data[site.config['metadata']].select { |item| item['objectid'] == featured_image }
          # provide error message if no matching item
          if featured_record.empty?
            puts color_text("Error cb_helpers: Item for featured image with objectid '#{featured_image}' not found in configured metadata '#{site.config['metadata']}'. Please check 'featured-image' in '_data/theme.yml'", :yellow)
          else
            # use object_location for image items, image_small for others
            if featured_record[0]['format'] and featured_record[0]['format'].include? 'image'
              featured_item_src = featured_record[0]['object_location'] || featured_record[0]['image_small']
            elsif featured_record[0]['display_template'] and featured_record[0]['display_template'].include? 'image'
              featured_item_src = featured_record[0]['object_location'] || featured_record[0]['image_small']
            else
              featured_item_src = featured_record[0]['image_small']
            end
            # provide error message if no matching image src
            if featured_item_src.nil? 
              puts color_text("Error cb_helpers: Item for featured image with objectid '#{featured_image}' does not have an image url in metadata. Please check 'featured-image' in '_data/theme.yml' and choose an item that has 'object_location' or 'image_small'", :yellow)
            end
            # use item title as alt
            featured_item_alt = featured_record[0]['title'] || site.config['title']
            # figure out item link
            if featured_record[0]['parentid']
              featured_item_link = "/items/" + featured_record[0]['parentid'] + ".html#" + featured_image
            else
              featured_item_link = "/items/" + featured_image + ".html"
            end
          end
        else
          puts color_text("Error cb_helpers: configured metadata '#{site.config['metadata']}' not found in '_data'.", :yellow)
        end

      end

      # add site.data.featured_item object with src, alt, and link 
      site.data['featured_item'] = { "src" => featured_item_src, "alt" => featured_item_alt, "link" => featured_item_link }

      #####
      #
      # Theme Icons
      # find icons configured in "theme.yml" or set defaults
      # return new variable --> site.data.theme_icons
      # containing keys for each icon, each with key for inline or symbol markup
      #
      #####

      # get list of existing icons in assets
      lib_icons = site.static_files.select { |file| file.path.include? '/assets/lib/icons/' }
      lib_icon_names = lib_icons.map { |i| i.basename }
      # get icons configured in theme.yml
      theme_icons = site.data['theme']['icons'] || { }
      # set default values for icons used in template in case nothing is configured
      if !theme_icons['icon-image']
        theme_icons['icon-image'] = "image"
      end
      if !theme_icons['icon-audio']
        theme_icons['icon-audio'] = "soundwave"
      end
      if !theme_icons['icon-video']
        theme_icons['icon-video'] = "film"
      end
      if !theme_icons['icon-pdf']
        theme_icons['icon-pdf'] = "file-richtext"
      end
      if !theme_icons['icon-record']
        theme_icons['icon-record'] = "file-text"
      end
      if !theme_icons['icon-compound-object']
        theme_icons['icon-compound-object'] = "collection"
      end
      if !theme_icons['icon-multiple']
        theme_icons['icon-multiple'] = "postcard"
      end
      if !theme_icons['icon-default']
        theme_icons['icon-default'] = "file-earmark"
      end
      if !theme_icons['icon-back-to-top']
        theme_icons['icon-back-to-top'] = "arrow-up-square"
      end
      if !theme_icons['arrow-left']
        theme_icons['arrow-left'] = "arrow-left"
      end
      if !theme_icons['arrow-right']
        theme_icons['arrow-right'] = "arrow-right"
      end
      if !theme_icons['arrow-down']
        theme_icons['arrow-down'] = "arrow-down"
      end
      # process icons
      icon_set = { }
      theme_icons.each do |i|
        # check if icon svg file exists in assets
        if !lib_icon_names.include? i[1]
          puts color_text("Error cb_helpers: configured icon '#{i[0]}: #{i[1]}' does not exist. Please check 'theme.yml' and 'assets/lib/icons'.", :yellow)
        else
          # find matching icon
          svg_file = lib_icons.find { |icon| icon.basename == i[1] }
          # open icon svg from assets
          file = File.open(svg_file.path, "rb").read
          # remove whitespace
          markup = normalize_whitespace(file)
          # create symbol style markup
          symbol_start = '<symbol id="' + i[0] + '"'
          symbol = markup.gsub('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"', symbol_start).gsub('</svg>','</symbol>')
          # add to icon set hash
          icon_set[i[0]] = { "inline" => markup, "symbol" => symbol }
        end
      end
      # add icon set to site data
      site.data['theme_icons'] = icon_set
 
    end

    # normalize whitespace
    # taken from Jekyll Filters
    def normalize_whitespace(input)
      input.to_s.gsub(%r!\s+!, " ").tap(&:strip!)
    end

    # Color helper, to add warning colors to message outputs
    # use like: puts color_text("example", :red)
    def text_colors
      @colors = {
        red: 31,
        yellow: 33,
        green: 32
      }
    end
    def color_text(str, color_code)
      "\e[#{text_colors[color_code]}m#{str}\e[0m"
    end

  end
end
