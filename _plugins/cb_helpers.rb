module CollectionBuilderHelperGenerator
  class Generator < Jekyll::Generator

    def generate(site)

      #####
      #
      # Featured Image 
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
        # find item in site metadata
        featured_record = site.data[site.config['metadata']].select { |item| item['objectid'] == featured_image }
        # provide error message if no matching item
        if featured_record.empty?
          puts color_text("Error cb_vars: Item for featured image with objectid '#{featured_image}' not found in configured metadata '#{site.config['metadata']}'. Please check 'featured-image' in '_data/theme.yml'", :yellow)
        else
          # use object_download for image items, image_small for others
          if featured_record[0]['format'] and featured_record[0]['format'].include? 'image'
            featured_item_src = featured_record[0]['object_download'] || featured_record[0]['image_small']
          else
            featured_item_src = featured_record[0]['image_small']
          end
          # provide error message if no matching image src
          if featured_item_src.nil? 
            puts color_text("Error cb_vars: Item for featured image with objectid '#{featured_image}' does not have an image url in metadata. Please check 'featured-image' in '_data/theme.yml' and choose an item that has 'object_download' or 'image_small'", :yellow)
          end
          featured_item_alt = featured_record[0]['title'] || site.config['title']
          featured_item_link = "/items/" + featured_image + ".html"
        end

      end

      # add site.data.featured_item object with src, alt, and link 
      site.data['featured_item'] = { "src" => featured_item_src, "alt" => featured_item_alt, "link" => featured_item_link }

      #####
      #
      # Icon Theme
      # find icons configured in "theme.yml" or set defaults
      # return new variable --> site.data.icon
      #
      #####

      # get list of existing icons in assets
      lib_icon_names = site.static_files.select { |file| file.path.include? '/assets/lib/icons/' }.map { |i| i.basename }
      # get icons configured in theme.yml
      theme_icons = site.data['theme']['icons'] || { "icon-default" => "file-earmark" }
      if !theme_icons['icon-image']
        theme_icons['icon-image'] = "image"
      end
      if !theme_icons['icon-audio']
        theme_icons['icon-audio'] = "file-play"
      end
      if !theme_icons['icon-video']
        theme_icons['icon-video'] = "film"
      end
      if !theme_icons['icon-pdf']
        theme_icons['icon-pdf'] = "file-richtext"
      end
      if !theme_icons['icon-default']
        theme_icons['icon-default'] = "file-earmark"
      end
      # check if icons exist
      theme_icons.each do |i|
        if !lib_icon_names.include? i[1]
          puts color_text("Error cb_vars: configured icon '#{i[0]}: #{i[1]}' does not exist. Please check 'theme.yml' and 'assets/lib/icons'.", :yellow)
        end
      end

      puts "#{theme_icons}"

      
      
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
