###############################################################################
# TASK: download_by_csv
#
# read csv, download using wget
###############################################################################

desc "download objects and rename using csv"
task :download_by_csv, [:csv_file,:download_link,:download_rename,:output_dir] do |_t, args|
  # set default arguments
  args.with_defaults(
    csv_file: 'download.csv',
    download_link: 'url',
    download_rename: 'filename_new',
    output_dir: 'download/'
  )

  # check for csv file
  if !File.exist?(args.csv_file)
    puts "CSV file does not exist! No files downloaded and exiting."
  else
    # read csv file
    csv_text = File.read(args.csv_file, :encoding => 'utf-8')
    csv_contents = CSV.parse(csv_text, headers: true)

    # Ensure that the output directory exists.
    FileUtils.mkdir_p(args.output_dir) unless Dir.exist?(args.output_dir)    
        
    # iterate on csv rows
    csv_contents.each do |item|
      # check for download url
      if item[args.download_link]
        # check for rename
        if item[args.download_rename]
          # check if file already exists
          name_new = File.join(args.output_dir, item[args.download_rename])
          if File.exist?(name_new)
            puts "new filename '#{name_new}' already exists, skipping!"
            next
          end
          puts "downloading"
          # call wget
          system('wget','-O', name_new, item[args.download_link])
        else
          puts "downloading"
          # call wget 
          system('wget', item[args.download_link], "-P", args.output_dir)
        end
      else
        puts "no download url!"
      end
    end

    puts "done downloading."

  end

end
