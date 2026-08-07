var _init_dropzone_for_images;

_init_dropzone_for_images = function init_dropzone_for_images() {
  if ( $("#basic-images").length ) {
    Dropzone.options.basicImages = {
      paramName: "image[image_file]", // The name that will be used to transfer the file
      maxFilesize: 150,
      timeout: 0,
      dictDefaultMessage: "Drag and drop images here or click to upload.",
      success: function(file, dataUrl) {
        $(file.previewElement).wrap('<a href="/images/'+dataUrl.id+'"></a>');
        file.previewElement.classList.add("dz-success");
      },   
      accept: function(file, done) {
        done();
      }
    };      
  }
};

var _init_dropzone_for_depictions;

_init_dropzone_for_depictions = function init_dropzone_for_depictions() {
  if ( $("#depiction-images").length ) {
    Dropzone.options.depictionImages = {
      paramName: "depiction[image_attributes][image_file]", // The name that will be used to transfer the file
      maxFilesize: 150,
      timeout: 0,
      accept: function(file, done) {
        done();
      }
    };
  }
};

$(document).on('turbolinks:load', function(event) {
  _init_dropzone_for_images();
  _init_dropzone_for_depictions();
});

Dropzone.autoDiscover = false; // disable the built-in autodiscovery
$(document).on("turbolinks:load", Dropzone.discover);
