# Objects Directory

The CollectionBuilder-CSV template includes this objects folder with demo objects. 
These can deleted when starting a new project. 

Generally, object files should NOT be committed to your GitHub repository (as Git is not designed for binary objects and has GitHub limits the overall size of your repository).

The location of your objects is set by the "object_download", "image_small", and "image_thumb" values included in your metadata. 
Each object's location can be different, hosted in a variety of options.
For example, objects can be in a folder contained inside the project, like the demo objects (e.g. the value of "object_download" would be `/objects/demo_001.jpg`).
Or hosted in a separate web accessible location (e.g. the value of "object_download" would be `https://www.lib.uidaho.edu/digital/example/demo_001.jpg`).

Check the documentation for details of Rake tasks to process object files and how find API links.
