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


$(document).on('page:change', function(event) {
  _init_dropzone_for_images();
  _init_dropzone_for_depictions();
});

$(document).on('ready page:load', function(event) {
  _init_dropzone_for_images()
  _init_dropzone_for_depictions();
});

Dropzone.autoDiscover = false; // disable the built-in autodiscovery
$(document).on("ready page:load", Dropzone.discover);
