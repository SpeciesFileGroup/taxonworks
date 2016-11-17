var _init_map_table;
var result_collection;

_init_map_table = function init_map_table() {
  if ($("#co_by_area_and_date").length) {
    if ($("#set_area_form").length) {
      var result_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
      //var area_selector = $("#geographic_area_id_for_by_area");
  
      $(".result_map_toggle").click(function (event) {           // switch to the map view
        $("#area_count").text('????');
        $("#show_list").attr('hidden', true);         // hide the list view
        $("#show_map").removeAttr('hidden');          // reveal the map
        $(".result_list_toggle").removeAttr('hidden');           // expose the other link
        $(".result_map_toggle").attr('hidden', true);
        $("[name='[geographic_area_id]']").attr('value', '');
        result_map = _init_simple_map();
        result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', result_collection);
      });
  
      $(".result_list_toggle").click(function (event) {          // switch to the list view
        $("#area_count").text('????');
        $("#show_map").attr('hidden', true);          // hide the map
        $("#show_list").removeAttr('hidden');         // reveal the area selector
        $(".result_map_toggle").removeAttr('hidden');            // expose the other link
        $(".result_list_toggle").attr('hidden', true);
        $("#drawn_area_shape").attr('value', '');
      });
  
      $("#set_taxon_name").click(function (event) {
          $("taxon_count").text('????');
        $("select_taxon_name").mx_spinner('show');
    
        // do the GET here.
        $("select_taxon_name").mx_spinner('hide');
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
          }, 'json'  // I expect a json response
          );
  
        event.preventDefault();
        }
      );
      // below could be used as template for auto-get on .overlaycomplete
      //$("#set_area").on("ajax:success", function (e, data) {
      //    $("#area_count").text(data.html);
      //    return true;
      //  }
      //).on("#ajax:errror", function (e, xhr, status, error) {
      //    $("area_count").text("<p>set_area error => " + error + "</p>")
      //  }
      //);
      $("#find_area_and_date_commit").click(function (event, href) {
        //$("#result_span").text('**********');
        if (href == undefined) {
          href = $("#set_area_form").serialize() + '&' + $("#set_date_form").serialize() + '&' + $("#set_taxon_name_form");
        }
        $("#find_item").mx_spinner('show');
        $.get('find', href, function (local_data) {
          //var html = local_data.html;
          //var message = local_data.message;
          ////result_collection = local_data.feature_collection;
          //if (message != undefined) {
          //  if (message.length == 0) {
          //    $("#result_span").text("Total: " + local_data.collection_objects_count);
          //  }
          //  else {
          //    $("#result_span").text(message);
          //  }
          //}
          ////$("#show_list").html(html);
          //if (local_data.feature_collection) {
          //  if ($("#show_map").attr("hidden") != "hidden") {
          //    //$("#show_map").removeAttr('hidden');
          //    result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', result_collection);
          //  }
          //}
            //processPagination();
          $("#find_item").mx_spinner('hide');
          }//, 'json'  // I expect a json response
        );
        event.preventDefault();
      })
    }
  
    function processPagination() {
      if ($('.pagination') != undefined) {
        //for (i = 0;$('.pagination').children.length; i++) {
        //  $('.pagination').children[i].children[0].attr['hrefUrl'] = $('.pagination').children[i].attr['href'];
        //}
      }
    }
  
    var today = new Date();
    var year = today.getFullYear();
    //today = today.toLocaleDateString('en-US', {year: 'numeric', month: '2-digit', day: '2-digit'});
    var format = 'yy/mm/dd';
    var dateInput;
  
  
    set_control($("#st_fixedpicker"), $("#search_start_date"), format, year, $("#early_date").text());
  
    set_control($("#en_fixedpicker"), $("#search_end_date"), format, year, $("#late_date").text());
  
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
        //input.val(on_day);
      }
    }
  
    $("#search_start_date").change(function (event) {
      update_and_graph(event)
    });    // listener for keyboard
  
    $("#search_end_date").change(function (event) {
      update_and_graph(event)
    });    // change of date
  
    $("#st_fixedpicker").change(function (event) {
      update_and_graph(event)
    });   // listener for day
  
    $("#en_fixedpicker").change(function (event) {
      update_and_graph(event)
    });   // click date change
    $("#partial_toggle").change(function (event) {
      update_and_graph(event)
    });   // click date change
  
    function update_and_graph(event) {
      $("#select_date_range").mx_spinner('show');
      $.get('set_date', $("#set_date_form").serialize(), function (local_data) {
          $("#date_count").text(local_data.html);
          $("#graph_frame").html(local_data.chart);
        $("#select_date_range").mx_spinner('hide');
          
        }, 'json'  // I expect a json response
      );
      event.preventDefault();
    }
  
    function dateFormat(date, fmt) {
      var o = {
        "M+": date.getMonth() + 1,
        "d+": date.getDate(),
      };
      if (/(y+)/.test(fmt)) {
        fmt = fmt.replace(RegExp.$1, (date.getFullYear() + "").substr(4 - RegExp.$1.length));
      }
      for (var k in o) {
        if (new RegExp("(" + k + ")").test(fmt)) {
          fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
        }
      }
      return fmt;
    }
  
    var startDate = new Date($("#early_date").text());
    var endDate = new Date($("#late_date").text());
    var offset = endDate - startDate;
  
    $("#double_date_range").rangepicker({
      type: "double",
      startValue: dateFormat(startDate, "yyyy/MM/dd"),
      endValue: dateFormat(endDate, "yyyy/MM/dd"),
      translateSelectLabel: function (currentPosition, totalPosition) {
        var timeOffset = offset * ( currentPosition / totalPosition);
        var date = new Date(+startDate + parseInt(timeOffset));
        return dateFormat(date, "yyyy/MM/dd");
      }
    });
  
    $("#double_date_range").mouseup(function (event) {
      var range_factor = 1.0;
      var newStartText = $(".label.select-label")[1].textContent;
      var newEndText = $(".label.select-label")[0].textContent;
      var newStartDate = (new Date(newStartText)) / range_factor;
      var newEndDate = range_factor * (new Date(newEndText));
      $("#search_start_date").val(newStartText);
      $("#search_end_date").val(newEndText);
      offset = (newEndDate - newStartDate);
      update_and_graph(event);
      $(".label.range-label")[0].textContent = $(".label.select-label")[1].textContent;
      $(".label.range-label")[1].textContent = $(".label.select-label")[0].textContent;
      $("#double_date_range").rangepicker({
        type: "double",
        startValue: newStartText,
        endValue: newEndText,
        translateSelectLabel: function (currentPosition, totalPosition) {
          var timeOffset = offset * ( currentPosition / totalPosition);
          var date = new Date(+newStartDate + parseInt(timeOffset));
          return dateFormat(date, "yyyy/MM/dd");
        }
      });
      }
    );
  
    $("#reset_slider").click(function (event) {
        var startDate = new Date($("#early_date").text());
        var endDate = new Date($("#late_date").text());
        var offset = endDate - startDate;
        $("#double_date_range").rangepicker({
          type: "double",
          startValue: dateFormat(startDate, "yyyy/MM/dd"),
          endValue: dateFormat(endDate, "yyyy/MM/dd"),
          translateSelectLabel: function (currentPosition, totalPosition) {
            var timeOffset = offset * ( currentPosition / totalPosition);
            var date = new Date(+startDate + parseInt(timeOffset));
            return dateFormat(date, "yyyy/MM/dd");
          }
        });
        $("#search_start_date").val($("#early_date").text());
        $("#search_end_date").val($("#late_date").text());
        update_and_graph(event);
        event.preventDefault();
      }
    );
  
    $("#toggle_slide_calendar").click(function () {
      $("#tr_slider").toggle();
      $("#tr_calendar").toggle();
      if ($("#toggle_slide_calendar").val() == 'Use Calendar') {
        $("#toggle_slide_calendar").val("Use Slider");
      }
      else {
        $("#toggle_slide_calendar").val("Use Calendar");
      }
    });
  
    $("#toggle_slide_calendar").click();    // set rendered display to design doc state
  
  }       // end of active code block
};

$(document).ready(_init_map_table);
$(document).on('page:load', _init_map_table);

