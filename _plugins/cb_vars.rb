module CollectionBuilderThemeGenerator
  class Generator < Jekyll::Generator

    def generate(site)

      #####
      #
      # Featured Image 
      # find featured image as configured in "theme.yml"
      # return site.data.featured_item with .src, .alt, .link
      #
      #####

      # find featured image in "theme.yml"
      featured_image = site.data['theme']['featured-image'] || "/assets/img/collectionbuilder-logo.png"
      
      if featured_image.include? "/"
        # if featured image is an external link
        featured_item_src = featured_image
        featured_item_alt = site.config['title']
        featured_item_link = featured_item_src
      else
        # if featured image is an objectid
        # find item in site metadata
        featured_record = site.data[site.config['metadata']].select { |item| item['objectid'] == featured_image }
        # error message if no matching item
        if featured_record.empty?
          puts color_text("Error cb_vars: Item for featured image with objectid '#{featured_image}' not found in configured metadata '#{site.config['metadata']}'. Please check 'featured-image' in '_data/theme.yml'", :yellow)
        else
          featured_item_src = featured_record[0]['object_download'] || featured_record[0]['image_small']
          # error message if no matching image src
          if featured_item_src.nil? 
            puts color_text("Error cb_vars: Item for featured image with objectid '#{featured_image}' does not have an image url in metadata. Please check 'featured-image' in '_data/theme.yml' and choose an item that has 'object_download' or 'image_small'", :yellow)
          end
          featured_item_alt = featured_record[0]['title'] || site.config['title']
          featured_item_link = "/items/" + featured_image + ".html"
        end

      end

      # add src, alt, and link to site.data.featured_item object
      site.data['featured_item'] = { "src" => featured_item_src, "alt" => featured_item_alt, "link" => featured_item_link }
      
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
