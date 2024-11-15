###############################################################################
# TASK: rename_lowercase
#
# copy files, rename all files to lowercase
###############################################################################

desc "rename lowercase"
task :rename_lowercase, [:input_dir,:output_dir] do |_t, args|
  # set default arguments
  args.with_defaults(
    input_dir: 'objects/',
    output_dir: 'renamed/'
  )

  # ensure input directory exists
  if !Dir.exist?(args.input_dir)
    puts "Input folder does not exist!"
    break
  end

  # ensure that the output directory exists.
  FileUtils.mkdir_p(args.output_dir) unless Dir.exist?(args.output_dir)
  
  # Generate derivatives.
  Dir.glob(File.join([args.input_dir, '*'])).each do |filename|
    # Ignore subdirectories.
    if File.directory? filename
      next
    end

    # Get the lowercase filename 
    name_old = filename
    name_new = File.join(args.output_dir, File.basename(filename).downcase)

    # check if file already exists
    if File.exist?(name_new)
      puts "new filename '#{name_new}' already exists, skipping!"
      next
    end

    # copy file
    puts "renaming: '#{name_old}' to '#{name_new}'"
    system('cp', name_old, name_new)

  end
end
