# resize_images

This task resizes all images (.jpeg, .jpg, .png, .tif, or .tiff) in a folder of files within this repository. 
It outputs the resized images to a new folder in this repository, with all filenames and extensions lowercased, and optionally converted into another image format.

Requirements:

- **ImageMagick**, [download](https://imagemagick.org/script/download.php)

Using defaults:

- Put all images in the "objects/" folder.
- run `rake resize_images` (images will be same format, resized to 3000 pixel max width and height while preserving aspect ratio)
- All images will be output to "resized/" folder.

The options can be changed by passing arguments with the rake command.

| option | description | default value |
| --- | --- | --- |
| new_size | resizing parameter following [ImageMagick geometry conventions](https://imagemagick.org/script/command-line-processing.php#geometry) | '3000x3000' |
| new_format | optionally change format of the image. Leave blank or provide a valid image extension starting with `.` (".jpg", ".png", ".tif") | false |
| input_dir | folder containing all the images | 'objects' |
| output_dir | folder to output the resized images | 'resized' |


The order follows [:new_size, :new_format, :input_dir, :output_dir].
For example, 

`rake resize_images["5000x5000",".jpg","raw_folder","new_folder"]`

