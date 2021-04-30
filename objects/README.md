# Objects Directory

The CollectionBuilder-SA template includes this objects folder with demo objects. 
These can deleted when starting a new project. 

The root directory holding your objects should be set in _config.yml > `objects` option. 
The location of your objects can be a folder, like this demo, contained inside the project (the value would be `objects: /objects`).
Alternatively, your objects can be hosted in separate web accessible location (the value would be a full URL, e.g. `https://www.lib.uidaho.edu/digital/example/`). 

Object files should NOT be committed to your GitHub repository (as Git is not designed for binary objects and has GitHub limits the overall size of your repository).
