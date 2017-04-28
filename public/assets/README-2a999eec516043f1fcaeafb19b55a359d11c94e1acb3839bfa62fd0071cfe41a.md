

Organization
------------

* views - maps 1:1 with a app/view files, i.e. used only for that file
* vendor - js that references libraries that aren't TW origin
* vendor/lib - TW wrappers/configuration of vendor provided js
* vendor/src - vendor provided js
* utilities - pure functions with no TW specific bindings (i.e. they should be their own external libraries)
* workbench - general TW code not associated with a specific view (e.g. binding with a DOM element) 

