var _init_dropzone_for_images;

_init_dropzone_for_images = function init_dropzone_for_images() {
  if ( $("#basic-images").length ) {
    Dropzone.options.basicImages = {
      paramName: "image[image_file]", // The name that will be used to transfer the file
      maxFilesize: 100,
      dictDefaultMessage: "Drag and drop images here or click to upload.",
      success: function(file, dataUrl) {
        $(file.previewElement).wrap('<a href="/images/'+dataUrl.result.id+'"></a>');
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
      maxFilesize: 100,
      accept: function(file, done) {
        done();
      }
    };
  }
};

var _init_dropzone_for_task_simple_specimen;

// https://github.com/enyo/dropzone/wiki/Combine-normal-form-with-Dropzone
_init_dropzone_for_task_simple_specimen = function init_dropzone_for_task_simple_specimen() {

  if ( $("#simple-specimen-task").length ) {
    Dropzone.options.simpleSpecimenTask = {
      autoProcessQueue: false,
      uploadMultiple: true,
      paramName: "specimen[image_array]",
      maxFiles: 100,
      maxFilesize: 100,
      previewsContainer: '#dropzone_previews',

      // The setting up of the dropzone
      init: function() {
        var myDropzone = this;

        // First change the button to actually tell Dropzone to process the queue.
        this.element.querySelector("#simple_create").addEventListener("click", function(e) {
          // Make sure that the form isn't actually being sent.
          e.preventDefault();
          e.stopPropagation();

          if (myDropzone.getQueuedFiles().length > 0) {
            myDropzone.processQueue();
          } else {
            return $('#simple-specimen-task').submit();
          }
        });

        this.on("addedfile", function(file) { $('.dz-default').remove(); });

        // Listen to the sendingmultiple event. In this case, it's the sendingmultiple event instead
        // of the sending event because uploadMultiple is set to true.
        this.on("sendingmultiple", function() {
          // Gets triggered when the form is actually being sent.
          // Hide the success button or the complete form.
        });
        this.on("successmultiple", function(files, response) {
          // Gets triggered when the files have successfully been sent.
          // Redirect user or notify of success.
          // alert(response.otu_id);

          // work with the json response to reset the form, which is then 
          // used in the GET request to reset the window

          TW.tasks.accessions.quick.simple.new_from_dropzone(response);
          // serialize and re-render the page
          return window.location.href = '/tasks/accessions/simple/new?' + $( "div.flexbox input" ).serialize();
        });
        this.on("errormultiple", function(files, response) {
          alert('error');
          // Gets triggered when there was an error sending the files.
          // Maybe show form again, and notify user of error
        });
        this.on("success", function(fields, response) {
          // return window.location.href = '/tasks/accessions/simple/new';
        });
      }
    };
  }
};

$(document).on('turbolinks:load', function(event) {
  _init_dropzone_for_task_simple_specimen();
  _init_dropzone_for_images();
  _init_dropzone_for_depictions();
});

Dropzone.autoDiscover = false; // disable the built-in autodiscovery
$(document).on("turbolinks:load", Dropzone.discover);
