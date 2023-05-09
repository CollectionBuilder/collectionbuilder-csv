# frozen_string_literal: true

#########
#
# CollectionBuilder Page Generator, v1.3-csv
#
# Jekyll plugin to generate pages from _data/ files.
# Designed to create Item pages from metadata CSV for digital collection sites.
# (c) 2021 CollectionBuilder, evanwill, https://github.com/CollectionBuilder/
# Distributed under the conditions of the MIT license
# 
# Originally inspired by jekyll-datapage_gen, https://github.com/avillafiorita/jekyll-datapage_gen
#
#########

module CollectionBuilderPageGenerator
  class ItemPageGenerator < Jekyll::Generator
    safe true
    # include jekyll utils so can use slugify
    include Jekyll::Utils

    # main function to read config, data, and generate pages
    def generate(site)

      #########
      #
      # Default Settings
      # 
      # These values are used if not configured in the 'page_gen' object in _config.yml
      # Defaults follow CollectionBuilder specific conventions.
      #
      data_file_default = site.config['metadata'] || 'metadata' # _data to use
      template_location_default = "item/" # folder in _layouts used to organize templates, ends with slash, empty if using root
      template_default = 'item' # layout to use for all pages by default
      display_template_default = 'display_template' # metadata column to use to assign layout
      name_default = 'objectid' # value to use for filename
      dir_default = 'items' # where to output pages
      extension_default = 'html' # extension, usually html
      filter_default = 'objectid' # value to filter records on, filters on objectid by default
      filter_condition_default = '!record["parentid"]' # expression to filter records on, default filters rows with a parentid
      #
      ######

      # get optional configuration from _config.yml, or create a single default one from CB metadata setting
      configure_gen = site.config['page_gen'] || [{ 'data' => data_file_default }]

      # iterate over each instance in configuration
      # this allows to generate from multiple _data sources
      configure_gen.each do |data_config|
        data_file = data_config['data'] || data_file_default
        template_location = data_config['template_location'] || template_location_default
        template = template_location + (data_config['template'] || template_default)
        display_template = data_config['display_template'] || display_template_default
        name = data_config['name'] || name_default
        dir = data_config['dir'] || dir_default
        extension = data_config['extension'] || extension_default
        filter = data_config['filter'] || filter_default
        filter_condition = data_config['filter_condition'] || filter_condition_default

        # check if data file exists, if not provide error message and skip
        if !site.data.key? data_file.split('.')[0]
          puts color_text("Error cb_page_gen: Data value '#{data_file}' does not match any site data. Please check _config.yml 'metadata' or page_gen 'data' value. Common issues are spelling error or including an extension such as .csv (no extension should be used!). Item pages are NOT being generated from '#{data_file}'!", :red)
          next
        end

        # Get the records to generate pages from
        # this splits on . to support a nested key in yml or json
        records = nil
        data_file.split('.').each do |level|
          if records.nil?
            records = site.data[level]
          else
            records = records[level]
          end
        end

        # Filter records if filter is configured (default is on objectid)
        if filter
          filtered_records = records.select { |r| r[filter] }
          filtered_number = records.size - filtered_records.size
          # provide notice if filter is applied
          puts color_text("Notice cb_page_gen: filter on '#{filter}' is applied. #{filtered_number} records are filtered because they do not have a value in '#{filter}'.", :green) if filtered_number != 0 
          records = filtered_records
        end
        # Filter records if filter_condition is configured
        if filter_condition
          filtered_records = records.select { |record| eval(filter_condition) } 
          filtered_number = records.size - filtered_records.size
          records = filtered_records
          # provide notice if non-default filter is applied
          if filter_condition != filter_condition_default 
            puts color_text("Notice cb_page_gen: filter_condition '#{filter_condition}' is applied. #{filtered_number} records are filtered.", :green) if filtered_number != 0 
          end
        end

        # Check for unique names, if not provide error message
        names_test = records.map { |x| x[name] }
        if names_test.size != names_test.uniq.size 
          puts color_text("Error cb_page_gen: some values in '#{name}' are not unique! This means those pages will overwrite each other, so you will be missing some Item pages. Please check '#{name}' and make them all unique.", :red) 
        end

        # Check for missing layouts
        template_test = records.map { |x| x[display_template] ? template_location + x[display_template].strip : template }.uniq
        all_layouts = site.layouts.keys
        missing_layouts = (template_test - all_layouts)
        if !missing_layouts.empty? # if there is missing layouts
          if all_layouts.include? template 
            # if there is a valid default layout fallback, continue
            puts color_text("Notice cb_page_gen: could not find layout(s) #{missing_layouts.join(', ')} in '_layouts/'. Records with these display_template will fallback to the default layout '#{template}'. If this is unexpected, please add the missing layout(s) or check configuration of 'template' and 'display_template' field.", :yellow)
          else
            # if there is no valid fallback / template
            puts color_text("Notice cb_page_gen: could not find layout(s) #{missing_layouts.join(', ')} in '_layouts/'. This includes the default layout '#{template}'. Please add the layout(s) or check configuration of 'template' and 'display_template'. Item pages will not be generated for records using the missing layouts!", :yellow)
            #next
          end
        end

        # Generate pages for each record
        records.each_with_index do |record, index|
          # Check for valid name, skip page gen if none
          if record[name].nil? || record[name].strip.empty?
            puts color_text("Notice cb_page_gen: record '#{index}' in '#{data_file}' does not have a value in '#{name}'! This record will be skipped.", :yellow)
            next
          end

          # create clean filename with Jekyll Slugify pretty mode
          # this ensures safe filenames, but may cause unintended issues with links if objectid are not well formed
          record['base_filename'] = slugify(record[name], mode: "pretty").to_s
          puts color_text("Notice cb_page_gen: record '#{index}' in '#{data_file}', '#{record[name]}' is being sanitized to create a valid filename. This may cause issues with links generated on other pages. Please check the naming convention used in '#{name}' field.", :yellow) if record['base_filename'] != record[name]

          # Provide index number for page object
          record['index_number'] = index 
          
          # Find next item 
          if index == records.size - 1
            next_item = records[0][name]
          else
            next_item = records[index + 1][name]
          end
          record['next_item'] = "/" + dir + "/" + slugify(next_item, mode: "pretty").to_s + "." + extension.to_s
          # Find previous item
          if index == 0
            previous_item = records[records.size - 1][name]
          else
            previous_item = records[index -1][name]
          end
          record['previous_item'] = "/" + dir + "/" + slugify(previous_item, mode: "pretty").to_s + "." + extension.to_s
          
          # Add layout value from display_template or the default
          if record[display_template]
            record['layout'] = template_location + record[display_template].strip
            # if not valid layout, fall back to template default
            if !all_layouts.include? record['layout']
              record['layout'] = template
            end
          else
            record['layout'] = template
          end
          # Check if layout exists, if not provide error message and skip
          if !all_layouts.include? record['layout']
            puts color_text("Error cb_page_gen: Could not find layout '#{record['layout']}'. Please check configuration or add the layout. Item page NOT generated for record '#{index}' in '#{data_file}'!", :red)
            next
          end

          # Pass the page data to the ItemPage generator
          site.pages << ItemPage.new(site, record, dir, extension)
        end
      end
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

  # Subclass of `Jekyll::Page` with custom method definitions.
  class ItemPage < Jekyll::Page

    # function to generate each individual page
    def initialize(site, record, dir, extension)
      @site = site             # the current site instance.
      @base = site.source      # path to the source directory.
      @dir  = dir         # the directory the page will output in
      
      @basename = record['base_filename']  # filename without the extension.
      @ext      = "." + extension.to_s  # the extension.
      @name     = record['base_filename'] + "." + extension.to_s # @basename + @ext.

      # add record data to the page
      # all record data will be available in page object
      @data = record

    end
  end

end
