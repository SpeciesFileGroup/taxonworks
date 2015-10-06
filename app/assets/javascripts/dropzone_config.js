Dropzone.options.myAwesomeDropzone = {
  paramName: "image[image_file]", // The name that will be used to transfer the file
  maxFilesize: 100, // MB
  accept: function(file, done) {
    if (file.name == "justinbieber.jpg") {
      done("Naha, you don't.");
    }
    else { done(); }
  }
};
