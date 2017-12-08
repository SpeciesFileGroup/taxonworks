let TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.otus = TW.views.tasks.otus || {};

Object.assign(TW.views.tasks.otus, {
  
  init: function () {
    
    let result_collection,
      that = this;
    
    if ($("#set_area_form").length) {
      let result_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
      //let area_selector = $("#geographic_area_id_for_by_area");
      
      $(".result_map_toggle").click(function (event) {           // switch to the map view
        that.switchMap();
      });
      
      $(".result_list_toggle").click(function (event) {          // switch to the list view
        that.switchList();
      });
      
      $("#toggle-list-map").on("click", function () {
        if ($(this).is(":checked")) {
          that.switchMap();
        }
        else {
          that.switchList();
        }
      });
      
      $("#set_area").click(function (event) {      // register the click handler for the made-from-scratch-button
          $("#area_count").text('----');
          $("#select_area").mx_spinner('show');
          $.get('set_area', $("#set_area_form").serialize(), function (local_data) {
            let popcorn = local_data;
            $("#area_count").text(local_data.html);
            $("#select_area").mx_spinner('hide');
            that.validateResultForFindOtu();
          }, 'json');
          event.preventDefault();
        }
      );

      $("#set_nomen").click(function (event) {
          $("#nomen_count").text('????');
          $("#select_nomen").mx_spinner('show');
          $.get('set_nomen', $("#set_nomen_form").serialize(), function (local_data) {
            $("#nomen_count").text(local_data.html);
            $("#select_nomen").mx_spinner('hide');
            that.validateResultForFindOtu();
          }, 'json');
          event.preventDefault();
        }
      );

      $("#set_author").click(function (event) {
          $("#author_count").text('????');
          $("#select_author").mx_spinner('show');
          $.get('set_author', $("#set_author_form").serialize(), function (local_data) {
            $("#author_count").text(local_data.html);
            $("#select_author").mx_spinner('hide');
            that.validateResultForFindOtu();
          }, 'json');
          event.preventDefault();
        }
      );

      $("#set_verbatim").click(function (event) {
          $("#verbatim_count").text('????');
          $("#select_verbatim").mx_spinner('show');
          $.get('set_verbatim', $("#set_verbatim_form").serialize(), function (local_data) {
            $("#verbatim_author_count").text(local_data.html);
            $("#select_verbatim").mx_spinner('hide');
            that.validateResultForFindOtu();
          }, 'json');
          event.preventDefault();
        }
      );

      $("#find_area_and_nomen_commit").click(function (event) {
        that.toggleFilter();
        that.ajaxRequest(event, "find");
      });
      
      $("#download_button").click(function (event) {
        if (that.validateMaxResults(1000)) {
          that.downloadForm(event);
        }
        else {
          TW.workbench.alert.create("To Download- refine result to less than 1000 records");
          return false;
        }
      });
    }

    // let today = new Date();
    // let year = today.getFullYear();
    // let format = 'yy/mm/dd';
    // let dateInput;
    //
    // this.validateResultForFindOtu();
    //
    // function set_control(control, input, format, year, st_en_day) {
    //   if (control.length) {
    //     control.datepicker({
    //       defaultDate: new Date(st_en_day),
    //       altField: input,
    //       dateFormat: format,
    //       changeMonth: true,
    //       changeYear: true,
    //       yearRange: "1700:" + year
    //     });
    //     input.val(st_en_day);
    //   }
    // }
    //
    // $(".filter-button").on("click", function () {
    //   that.toggleFilter();
    // });
    //
    // let startDate = new Date($("#earliest_date").text());
    // let endDate = new Date($("#latest_date").text());
    // let offset = endDate - startDate;
    //
    // this.updateRangePicker(startDate, endDate);
    //
    // $("#double_date_range").mouseup(function (event) {
    //   let range_factor = 1.0;
    //   let newStartText = $(".label.select-label")[1].textContent;
    //   let newEndText = $(".label.select-label")[0].textContent;
    //   let newStartDate = (new Date(newStartText)) / range_factor;
    //   let newEndDate = range_factor * (new Date(newEndText));
    //   $("#search_start_date").val(newStartText);
    //   $("#search_end_date").val(newEndText);
    //
    //   that.update_and_graph(event);
    //   $(".label.range-label")[0].textContent = $(".label.select-label")[1].textContent;
    //   $(".label.range-label")[1].textContent = $(".label.select-label")[0].textContent;
    //
    //   //Synchronize datapicker with rangepicker
    //   $("#st_fixedpicker").datepicker("setDate", new Date(dateFormat(new Date(newStartText), "yyyy/MM/dd")));
    //   $("#en_fixedpicker").datepicker("setDate", new Date(dateFormat(new Date(newEndText), "yyyy/MM/dd")));
    //
    //   that.updateRangePicker(newStartDate, newEndDate);
    //
    // });
    //
    //   $("#reset_slider").click(function (event) {
    //       $("#search_start_date").val($("#earliest_date").text());
    //       $("#search_end_date").val($("#latest_date").text());
    //       that.updateRangePicker(startDate, endDate);
    //       $("#graph_frame").empty();
    //       $("#date_count").text("????");
    //       that.validateResultForFindOtu();
    //       event.preventDefault();
    //     }
    //   );
    //
    //   // TODO: toggle_slide_calendar no longer exists in the HTML, should be removed from This module
    //   // $("#toggle_slide_calendar").click(function () {
    //   //   $("#tr_slider").toggle(250);
    //   //   $("#tr_calendar").toggle(250);
    //   //   if ($("#toggle_slide_calendar").val() == 'Use Calendar') {
    //   //     $("#toggle_slide_calendar").val("Use Slider");
    //   //   }
    //   //   else {
    //   //     $("#toggle_slide_calendar").val("Use Calendar");
    //   //   }
    //   // });
    //   $(".map_toggle").remove();
    //   $(".on_selector").remove();
    // },
    //
    // updateUserDateRange: function () {
    //   // let newStartText = $(".label.select-label")[1].textContent;
    //   // let newEndText = $(".label.select-label")[0].textContent;
    //   // let newStartDate = (new Date(newStartText)) / range_factor;
    //   // let newEndDate = range_factor * (new Date(newEndText));
    //   // $("#search_start_date").val(newStartText);
    //   // $("#search_end_date").val(newEndText);
    //   alert();
    //
    //   $("#ud_st_fixedpicker").datepicker("setDate", new Date(dateFormat(new Date('1700/01/01'), "yyyy/MM/dd")));
    //   $("#ud_en_fixedpicker").datepicker("setDate", new Date(dateFormat(new Date('2017/10/12'), "yyyy/MM/dd")));
  },
  
  switchMap: function () {
    $("#paging_span").hide();
    $("#show_list").hide();         // hide the list view
    $("#show_map").show();          // reveal the map
    $(".result_list_toggle").removeAttr('hidden');           // expose the other link
    $(".result_map_toggle").attr('hidden', 'hidden');
    $("[name='[geographic_area_id]']").attr('value', '');
    TW.vendor.lib.google.maps.loadGoogleMapsAPI().then(resolve => {
      this.result_map = TW.views.shared.gis.simple_map.init();
      this.result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', result_collection);
    });
  },
  
  switchList: function () {
    $("#show_map").hide();          // hide the map
    $("#show_list").show();         // reveal the area selector
    $(".result_map_toggle").removeAttr('hidden');            // expose the other link
    $(".result_list_toggle").attr('hidden', 'hidden');
    $("#drawn_area_shape").attr('value', '');
    $("#paging_span").show();
  },

  // update_and_graph: function (event) {
  //   let that = this;
  //
  //   this.validateDate(event.target);
  //   if (this.validateDates()) {
  //     this.updateRangePicker(new Date($("#search_start_date").val()), new Date($("#search_end_date").val()));
  //     $("#select_date_range").mx_spinner('show');
  //     $.get('set_date', $("#set_date_form").serialize(), function (local_data) {
  //       $("#date_count").text(local_data.html);
  //       $("#graph_frame").html(local_data.chart);
  //       $("#select_date_range").mx_spinner('hide');
  //       that.validateResultForFindOtu();
  //     }, 'json');  // I expect a json response
  //   }
  //   event.preventDefault();
  // },
  
  cleanResults: function () {
    $("#show_list").empty();
    $("#result_span").empty();
    $("#paging_span").empty();
  },
  
  toggleFilter: function () {
    $("#result_view").toggle();
  },
  
  validateMaxResults: function (value) {
    if (Number($("#result_span").text()) <= value) {
      return true;
    }
    return false;
  },
  
  validateResultForFindOtu: function () {
    // let i = 0;

    if (($("#area_count").text() > 0) || ($("#nomen_count").text() > 0) || ($("#author_count").text() > 0) || ($("#verbatim_author_count").text() > 0)) {
      $("#find_area_and_nomen_commit").removeAttr("disabled");
    }
    else {
      $("#find_area_and_nomen_commit").attr("disabled", "disabled");
      $("#download_button").attr("disabled", "disabled");
    }
    this.cleanResults();
  },
  
  updateRangePicker: function (newStartDate, newEndDate) {
    let offset = newEndDate - newStartDate;
    
    $("#double_date_range").rangepicker({
      type: "double",
      startValue: newStartDate,
      endValue: newEndDate,
      translateSelectLabel: function (currentPosition, totalPosition) {
        let timeOffset = offset * ( currentPosition / totalPosition);
        let date = new Date(+newStartDate + parseInt(timeOffset));
        return dateFormat(date, "yyyy/MM/dd");
      }
    });
  },
  
  serializeFields: function () {
    let data = '';
    let params = [];
    
    if ($('#area_count').text() != '????') {
      params.push($("#set_area_form").serialize());
    }

    if ($('#nomen_count').text() != '????') {
      params.push($("#set_nomen_form").serialize());
    }

    if ($('#author_count').text() != '????') {
      params.push($("#set_author_form").serialize());
    }

    if ($('#verbatim_count').text() != '????') {
      params.push($("#set_verbatim_form").serialize());
    }

    return data = params.join("&");
  },
  
  downloadForm: function (event) {
    event.preventDefault;
    if (this.validateMaxResults(1000)) {
      $('#download_form').attr('action', "download?" + this.serializeFields()).submit();
    }
    else {
      $("body").append('<div class="alert alert-error"><div class="message">To Download- refine result to less than 1000 records</div><div class="alert-close"></div></div>');
      return false;
    }
  },
  
  ajaxRequest: function (event, href) {
    // if (this.validateDates() && this.validateDateRange()) {
    $("#find_item").mx_spinner('show');
    $.get(href, this.serializeFields(), function (local_data) {
      // $("#find_item").mx_spinner('hide');  # this has been relocated to .../find.js.erb
    });//, 'json'  // I expect a json response
    $("#download_button").removeAttr("disabled");
    // }
    // else {
    //   $("body").append('<div class="alert alert-error"><div class="message">Incorrect dates</div><div class="alert-close"></div></div>');
    // }
    event.preventDefault();
  },
  
  validateDate: function (value) {
    if (is_valid_date($(value).val())) {
      $(value).val(convert_date_to_string($(value).val())); // Update the value of input field to prevent bad date with zero
      $(value).parent().find(".warning-date").text("");
    }
    else {
      $(value).parent().find(".warning-date").text("Invalid date, please verify you're using the correct format: (yyyy/mm/dd)");
    }
  },
  
  validateDates: function () {
    return (is_valid_date($("#search_start_date").val())) && is_valid_date($("#search_end_date").val());
  },
  
  validateDateRange: function () {
    return (new Date($("#search_start_date").val())) < (new Date($("#search_end_date").val()));
  }
});


$(document).on("turbolinks:load", function () {
  if ($("#otu_by_area_and_nomen").length) {
    let _init_map_table = TW.views.tasks.otus;
    _init_map_table.init();
  }
});
