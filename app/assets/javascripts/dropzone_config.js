var _init_dropzone_for_images;

_init_dropzone_for_images = function init_dropzone_for_images() {
  if ( $("#my-awesome-dropzone").length ) {
    Dropzone.options.myAwesomeDropzone = {
      paramName: "image[image_file]", // The name that will be used to transfer the file
      maxFilesize: 100,
      accept: function(file, done) {
        // if (file.name == "justinbieber.jpg") {
        //  done("Naha, you don't.");
       // }
      //  else {
          done();
      //  }
      }
    };
  }
};

// $(document).on('page:change', _init_dropzone_for_images)

$(document).on('page:change', function () {
  _init_dropzone_for_images()
});


// $(document).ready();
// $(document).on("page:load", _init_dropzone_for_images);



