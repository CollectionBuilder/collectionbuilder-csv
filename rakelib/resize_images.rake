###############################################################################
# TASK: resize_images
#
# create smaller images for all image files in the 'objects' folder
# requires ImageMagick installed!
###############################################################################

require 'mini_magick'

def process_image(filename, output_filename, size)
  puts "Creating: #{output_filename}"
  begin
    # use mini_magick to call ImageMagick
    MiniMagick.convert do |convert|
      convert << filename
      convert.resize(size)
      convert.flatten
      convert << output_filename
    end
  rescue StandardError => e
    puts "Error creating #{filename}: #{e.message}"
  end
end


desc 'Resize image files from folder'
task :resize_images, [:new_size, :new_format, :input_dir, :output_dir] do |_t, args|
  # set default arguments
  args.with_defaults(
    new_size: '3000x3000',
    new_format: false,
    input_dir: 'objects',
    output_dir: 'resized'
  )

  # set the folder locations
  objects_dir = args.input_dir
  output_dir = args.output_dir
  new_size = args.new_size

  # ensure input directory exists
  if !Dir.exist?(objects_dir)
    puts "Input folder does not exist! resize_images not run."
    exit
  end

  # ensure output directory exists
  FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
  
  # support these file extensions
  EXTNAME_TYPE_MAP = {
    '.jpeg' => :image,
    '.jpg' => :image,
    '.png' => :image,
    '.tif' => :image,
    '.tiff' => :image
  }.freeze

  # set new format
  if args.new_format != false 
    # check for valid extension
    if EXTNAME_TYPE_MAP[args.new_format]
      new_format = args.new_format
    else 
      puts "Invalid new format #{args.new_format}. resize_images not run."
      exit
    end
  else 
    new_format = false
  end

  # Iterate over all files in the objects directory.
  Dir.glob(File.join(objects_dir, '*')).each do |filename|
    
    # Skip subdirectories 
    if File.directory?(filename)
      next
    end

    # Determine the file type and skip if unsupported.
    extname = File.extname(filename).downcase
    file_type = EXTNAME_TYPE_MAP[extname]
    unless file_type
      puts "Skipping file with unsupported extension: #{filename}"
      next
    end

    # Get the lowercase filename without any leading path and extension.
    base_filename = File.basename(filename, '.*').downcase

    # Create new filename
    if args.new_format != false 
      new_extension = new_format
    else 
      new_extension = extname 
    end
    new_filename = File.join(output_dir, "#{base_filename}#{new_extension}")

    # check if file already exists
    if File.exist?(new_filename)
      puts "new filename '#{new_filename}' already exists, skipping!"
      next
    else 
      # resize
      process_image(filename, new_filename, new_size)
    end
    
  end
  
  puts "\e[32mImages output to '#{output_dir}'.\e[0m"
end
