var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collection_objects = TW.views.tasks.collection_objects || {};

Object.assign(TW.views.tasks.collection_objects, {

  init: function() {

    var result_collection,
    that = this;

    if ($("#set_area_form").length) {
        var result_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
        //var area_selector = $("#geographic_area_id_for_by_area");

        $(".result_map_toggle").click(function (event) {           // switch to the map view
          that.switchMap();
        });

        $(".result_list_toggle").click(function (event) {          // switch to the list view
          that.switchList();
        });

        $("#toggle-list-map").on("click", function() {
          if($(this).is(":checked")) {
            that.switchMap();
          } 
          else {
            that.switchList();
          }
        });

        $("#set_otu").click(function (event) {
          $("#otu_count").text('????');
          $("#select_otu").mx_spinner('show');

          $.get('set_otu', $("#set_otu_form").serialize(), function (local_data) {
            $("#otu_count").text(local_data.html);
            $("#select_otu").mx_spinner('hide');
            that.validateResult();
            }, 'json');
            event.preventDefault();
          }
        );
        
        $("#set_area").click(function (event) {      // register the click handler for the made-from-scratch-button
          $("#area_count").text('????');
            //var geo_id = $("input[name='[geographic_area_id]']").val();
            $("#select_area").mx_spinner('show');
            $.get('set_area', $("#set_area_form").serialize(), function (local_data) {
              var popcorn = local_data;
              $("#area_count").text(local_data.html);
              $("#select_area").mx_spinner('hide');
              that.validateResult();
            }, 'json'  // I expect a json response
            );

            event.preventDefault();
          }
          );

        $("#find_area_and_date_commit").click(function (event) {
          that.toggleFilter();
          that.ajaxRequest(event, "find");
        });

        $("#download_button").click(function (event) {
          if(that.validateMaxResults(1000)) {
            that.downloadForm(event);
          }
          else {
            TW.workbench.alert.create("To Download- refine result to less than 1000 records");          
            return false;
          }
        });    
      }

      var today = new Date();
      var year = today.getFullYear();
      var format = 'yy/mm/dd';
      var dateInput;

      this.validateResult();
      
      set_control($("#search_start_date"), $("#search_start_date"), format, year, $("#earliest_date").text());
      set_control($("#search_end_date"), $("#search_end_date"), format, year, $("#latest_date").text());

      function set_control(control, input, format, year, st_en_day) {
        if (control.length) {
          control.datepicker({
            defaultDate: new Date(st_en_day),
            altField: input,
            dateFormat: format,
            changeMonth: true,
            changeYear: true,
            yearRange: "1700:" + year
          });
          input.val(st_en_day);
        }
      }

      $(".filter-button").on("click", function() {
        that.toggleFilter();
      });

      $("#search_start_date").change(function (event) {
        that.update_and_graph(event)
      });    // listener for keyboard

      $("#search_end_date").change(function (event) {
        that.update_and_graph(event)
      });    // change of date

      $("#st_fixedpicker").change(function (event) {
        that.update_and_graph(event)
      });   // listener for day

      $("#en_fixedpicker").change(function (event) {
        that.update_and_graph(event)
      });   // click date change
      $("#partial_toggle").change(function (event) {
        if ($("#date_count").text() != "????") {
          that.update_and_graph(event)
        }
      });   // click date change


      var startDate = new Date($("#earliest_date").text());
      var endDate = new Date($("#latest_date").text());
      var offset = endDate - startDate;

      this.updateRangePicker(startDate, endDate);

      $("#double_date_range").mouseup(function (event) {
        var range_factor = 1.0;
        var newStartText = $(".label.select-label")[1].textContent;
        var newEndText = $(".label.select-label")[0].textContent;
        var newStartDate = (new Date(newStartText)) / range_factor;
        var newEndDate = range_factor * (new Date(newEndText));
        $("#search_start_date").val(newStartText);
        $("#search_end_date").val(newEndText);

        that.update_and_graph(event);
        $(".label.range-label")[0].textContent = $(".label.select-label")[1].textContent;
        $(".label.range-label")[1].textContent = $(".label.select-label")[0].textContent;

        //Synchronize datapicker with rangepicker
        $("#st_fixedpicker").datepicker("setDate", new Date(dateFormat(new Date(newStartText), "yyyy/MM/dd")));
        $("#en_fixedpicker").datepicker("setDate", new Date(dateFormat(new Date(newEndText), "yyyy/MM/dd")));

        that.updateRangePicker(newStartDate, newEndDate);

      });

      $("#reset_slider").click(function (event) {
        $("#search_start_date").val($("#earliest_date").text());
        $("#search_end_date").val($("#latest_date").text());
        that.updateRangePicker(startDate, endDate);
        $("#graph_frame").empty();
        $("#date_count").text("????");
        that.validateResult();
        event.preventDefault();
      }
      );

      $("#toggle_slide_calendar").click(function () {
        $("#tr_slider").toggle(250);
        $("#tr_calendar").toggle(250);
        if ($("#toggle_slide_calendar").val() == 'Use Calendar') {
          $("#toggle_slide_calendar").val("Use Slider");
        }
        else {
          $("#toggle_slide_calendar").val("Use Calendar");
        }
      });
      $(".map_toggle").remove();
      $(".on_selector").remove();
    },

    switchMap: function() {
      $("#paging_span").hide();
      $("#show_list").hide();         // hide the list view
      $("#show_map").show();          // reveal the map
      $(".result_list_toggle").removeAttr('hidden');           // expose the other link
      $(".result_map_toggle").attr('hidden', true);
      $("[name='[geographic_area_id]']").attr('value', '');        
      this.result_map = _init_simple_map();
      this.result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', result_collection);
    },

    switchList: function() {
      $("#show_map").hide();          // hide the map
      $("#show_list").show();         // reveal the area selector
      $(".result_map_toggle").removeAttr('hidden');            // expose the other link
      $(".result_list_toggle").attr('hidden', true);
      $("#drawn_area_shape").attr('value', '');  
      $("#paging_span").show();
    },    

    update_and_graph: function(event) {  
      var that = this;    

      this.validateDate(event.target);
      if(this.validateDates()) { 
        this.updateRangePicker(new Date($("#search_start_date").val()), new Date($("#search_end_date").val())); 
        $("#select_date_range").mx_spinner('show');
        $.get('set_date', $("#set_date_form").serialize(), function (local_data) {
          $("#date_count").text(local_data.html);
          $("#graph_frame").html(local_data.chart);
          $("#select_date_range").mx_spinner('hide');  
          that.validateResult();  
        }, 'json');  // I expect a json response        
      }
      event.preventDefault();
    },    

    cleanResults: function() {
      $("#show_list").empty();
      $("#result_span").empty();
      $("#paging_span").empty();
    },

    toggleFilter: function() {
      $("#result_view").toggle();   
    },    

    validateMaxResults: function(value) {
      if(Number($("#result_span").text()) <= value) {
        return true;
      }
      return false;
    },

    validateResult: function() {
      var i = 0;

      if(($("#date_count").text() > 0) || ($("#area_count").text() > 0) || ($("#otu_count").text() > 0)){
        $("#find_area_and_date_commit").removeAttr("disabled");
      }
      else {
        $("#find_area_and_date_commit").attr("disabled", "disabled");
        $("#download_button").attr("disabled", "disabled");
      }
      this.cleanResults();
    },

    updateRangePicker: function(newStartDate, newEndDate) {
      var offset = newEndDate - newStartDate;

      $("#double_date_range").rangepicker({
        type: "double",
        startValue: newStartDate,
        endValue: newEndDate,
        translateSelectLabel: function (currentPosition, totalPosition) {
          var timeOffset = offset * ( currentPosition / totalPosition);
          var date = new Date(+newStartDate + parseInt(timeOffset));
          return dateFormat(date, "yyyy/MM/dd");
        }
      });
    },

    serializeFields: function() {
      var data = '';
      var params = [];

      if ( $('#area_count').text() != '????' ) {
        params.push($("#set_area_form").serialize());
      }

      if ( $('#date_count').text() != '????' ) {    
        params.push($("#set_date_form").serialize());
      }

      if ( $('#otu_count').text() != '????' ) {
        params.push($("#set_otu_form").serialize());
      }

      return data = params.join("&");
    },

    downloadForm: function(event) {
      event.preventDefault;
      if(this.validateMaxResults(1000)) {
        $('#download_form').attr('action', "download?" + this.serializeFields()).submit();
      }
      else {
        $("body").append('<div class="alert alert-error"><div class="message">To Download- refine result to less than 1000 records</div><div class="alert-close"></div></div>');          
        return false;
      }
    },     

    ajaxRequest: function(event, href) {
      if(this.validateDates() && this.validateDateRange()) {   
        $("#find_item").mx_spinner('show');
        $.get(href, this.serializeFields(), function (local_data) {
              // $("#find_item").mx_spinner('hide');  # this has been relocated to .../find.js.erb
            });//, 'json'  // I expect a json response
        $("#download_button").removeAttr("disabled");
      }          
      else {
        $("body").append('<div class="alert alert-error"><div class="message">Incorrect dates</div><div class="alert-close"></div></div>');
      }
      event.preventDefault();
    },    

    validateDate: function(value) {
      if (is_valid_date($(value).val())) { 
          $(value).val(convert_date_to_string($(value).val())); // Update the value of input field to prevent bad date with zero
          $(value).parent().find(".warning-date").text("");
        }
        else {
          $(value).parent().find(".warning-date").text("Invalid date, please verify you're using the correct format: (yyyy/mm/dd)");
        }
      },

      validateDates: function() {
        return (is_valid_date($("#search_start_date").val())) && is_valid_date($("#search_end_date").val());
      },

      validateDateRange: function() {
        return (new Date($("#search_start_date").val())) < (new Date($("#search_end_date").val()));
      }          
    });


$(document).ready( function() {
  if ($("#co_by_area_and_date").length) {
    var _init_map_table = TW.views.tasks.collection_objects;
    _init_map_table.init();
  }
});