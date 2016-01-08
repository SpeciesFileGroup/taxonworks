var _init_dropzone_for_images;

_init_dropzone_for_images = function init_dropzone_for_images() {
  if ( $("#basic-images").length ) {
    Dropzone.options.basicImages = {
      paramName: "image[image_file]", // The name that will be used to transfer the file
      maxFilesize: 100,
      accept: function(file, done) {
        done();
      }
    };
  }
};

var _init_dropzone_for_depictions;

_init_dropzone_for_depictions = function init_dropzone_for_images() {
  if ( $("#depiction-images").length ) {
    Dropzone.options.depictionImages = {
      paramName: "depiction[image_attributes][image_file]", // The name that will be used to transfer the file
      maxFilesize: 100,
      accept: function(file, done) {
        done();
      }
    };
  }
};

var _init_dropzone_for_task_simple_specimen;

_init_dropzone_for_task_simple_specimen = function init_dropzone_for_task_simple_specimen() {
  if ( $("#simple-specimen").length ) {
  
  alert();
    Dropzone.options.simpleSpecimen = {
      paramName: "specimen[depiction][image_attributes][image_file]", // The name that will be used to transfer the file
      maxFilesize: 100,
      accept: function(file, done) {
        done();
      }
    };
  }
};




$(document).on('page:change', function(event) {
  _init_dropzone_for_images();
  _init_dropzone_for_depictions();
  _init_dropzone_for_task_simple_specimen();
});

$(document).on('ready page:load', function(event) {
  _init_dropzone_for_images()
  _init_dropzone_for_depictions();
  _init_dropzone_for_task_simple_specimen();
});

Dropzone.autoDiscover = false; // disable the built-in autodiscovery
$(document).on("ready page:load", Dropzone.discover);
