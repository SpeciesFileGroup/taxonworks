//
//  !! See also dropzone_config.js for behaviour
//
var TW = TW || {};
TW.tasks = TW.tasks || {};
TW.tasks.accessions = TW.tasks.accessions || {};
TW.tasks.accessions.quick = TW.tasks.accessions.quick || {};

TW.tasks.accessions.quick.simple = {

  init: function () {
    $('#simple-specimen-task').each(function () {
      TW.tasks.accessions.quick.simple.initialize($(this));
    });
  },

  initialize: function (div) {
    // Bind injected datepicker elements
    $('body').on('click',".collecting_event_picklist", function() {
      TW.tasks.accessions.quick.simple.bind_select_collecting_event(this);
    });

    $(".data:empty").parent().remove();

    TW.tasks.accessions.quick.simple.bind_locality_search(); 
    TW.tasks.accessions.quick.simple.bind_collecting_event_toggle(); 
  },

   // cleanup existing "new" records, so they are not resubmitted
  new_from_dropzone: function (response) {
    
    // OTU
    $("#selected_otu_id").remove();
    $("#XXX_otu_picker_autocomplete").remove();

    $('<input>')
      .attr('name', 'specimen[taxon_determinations_attributes][0][otu_id]')
      .attr('id', 'selected_otu_id')
      .attr('value', response.otu_id)
      .appendTo('#simple-specimen-task');

    // Collecting Event
   
    $("#selected_collecting_event_id").remove();
    $('<input>')
      .attr('name', 'specimen[collecting_event_id]')
      .attr('id', 'selected_collecting_event_id')
      .attr('value', response.collecting_event_id)
      .appendTo('#selected_collecting_event');
    
    // Likely need Repository here
  },

  bind_select_collecting_event: function (link) {
    TW.tasks.accessions.quick.simple.set_collecting_event( $(link).data('collecting-event-id') ); 
  },

  set_collecting_event: function (id) {
    $("#collecting_event_fields").hide(); 

    var form = $('#simple-specimen-task');
    var target = "#selected_collecting_event" ;
    var s = $(target);

    $.ajax({
      url: "/collecting_events/" + id + "/card", 
      dataType: "script",
      data: { 
        target: target,
      }
    });

    $('<input>')
      .attr('name', 'specimen[collecting_event_id]') 
      .attr('value', id)
      .attr('hidden', true)
      .appendTo(form); // form

    $('#collecting_event_form_toggle').show(); 
  },

  bind_locality_search: function () {
    $( "#verbatim_locality" ).keyup(function() {

      //   TW.tasks.accessions.quick.simple.update_collecting_events();

      var term =  $("#verbatim_locality").val();
      $.ajax({
        url: "collecting_events", 
          dataType: "script",
            data: { term: term  }
      });

    });
  },

  bind_collecting_event_toggle: function () {
    $('#collecting_event_form_toggle').on('click', function (){
      $('#collecting_event_fields').toggle();
      $('#selected_collecting_event').html('');
      $('#collecting_event_form_toggle').toggle();
    });
  }

}; // end widget 

$(document).on('turbolinks:load', TW.tasks.accessions.quick.simple.init);
