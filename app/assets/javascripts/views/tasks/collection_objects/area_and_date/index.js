var _init_map_table;

_init_map_table = function init_map_table() {
  if ($("#co_by_area_and_date").length) {
    if ($("#set_area_form").length) {
      var result_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
      var result_collection;
      //var area_selector = $("#geographic_area_id_for_by_area");

      $(".result_map_toggle").click(function (event) {           // switch to the map view
        $("#area_count").text('####');
        $("#show_list").attr('hidden', true);         // hide the list view
        $("#show_map").removeAttr('hidden');          // reveal the map
        $(".result_list_toggle").removeAttr('hidden');           // expose the other link
        $(".result_map_toggle").attr('hidden', true);
        $("[name='[geographic_area_id]']").attr('value', '');
        result_map = _init_simple_map();
        result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', result_collection);
      });

      $(".result_list_toggle").click(function (event) {          // switch to the list view
        $("#area_count").text('####');
        $("#show_map").attr('hidden', true);          // hide the map
        $("#show_list").removeAttr('hidden');         // reveal the area selector
        $(".result_map_toggle").removeAttr('hidden');            // expose the other link
        $(".result_list_toggle").attr('hidden', true);
        $("#drawn_area_shape").attr('value', '');
      });

      $("#set_area").click(function (event) {      // register the click handler for the made-from-scratch-button
          $("#area_count").text('----');
          //var geo_id = $("input[name='[geographic_area_id]']").val();
          $.get('set_area', $("#set_area_form").serialize(), function (local_data) {
              var popcorn = local_data;
              $("#area_count").text(local_data.html);
            }, 'json'  // I expect a json response
          );

          event.preventDefault();
        }
      );
      //event.preventDefault();
      //$("#set_area").on("ajax:success", function (e, data) {
      //    $("#area_count").text(data.html);
      //    return true;
      //  }
      //).on("#ajax:errror", function (e, xhr, status, error) {
      //    $("area_count").text("<p>set_area error => " + error + "</p>")
      //  }
      //);
      $("#find_area_and_date_commit").click(function (event) {
        //$("#result_span").text('**********');
        $.get('find', $("#set_area_form").serialize() + '&' + $("#set_date_form").serialize(), function (local_data) {
          var html = local_data.html;
          var message = local_data.message;
          result_collection = local_data.feature_collection;
          if (message.length == 0) {
            $("#result_span").text("Total: " + local_data.collection_objects_count);
            }
          else {
            $("#result_span").text(message);
            }
          $("#show_list").html(html);
          if (local_data.feature_collection) {
            if ($("#show_map").attr("hidden") != "hidden") {
              //$("#show_map").removeAttr('hidden');
              result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', result_collection);
            }
          }
          }, 'json'  // I expect a json response
        );
        event.preventDefault();
      })
    }

    var today = new Date();
    var year = today.getFullYear();
    //today = today.toLocaleDateString('en-US', {year: 'numeric', month: '2-digit', day: '2-digit'});
    var format = 'yy/mm/dd';
    var dateInput;

    //if ($("#st_fixedpicker").length) {  // see if we need a datepicker for start date
    //  var d = new Date();
    //  var n = d.getFullYear();
    //  //var dateInput = $("#st_flexpicker");
    //  //var format = 'yy/mm/dd';
    //
    //  $("#st_fixedpicker").datepicker({
    //    altField: "#st_flexpicker",
    //    dateFormat: format,
    //    changeMonth: true,
    //    changeYear: true,
    //    yearRange: "1700:" + n
    //  });
    //  //dateInput.datepicker({dateFormat: format});
    //  //dateInput.datepicker('setDate', $.datepicker.parseDate(format, dateInput.val()));
    //}
    //if ($("#en_fixedpicker").length) {  /// see if we need a datepicker for end date
    //  var d = new Date();
    //  var n = d.getFullYear();
    //  //var dateInput = $("#en_flexpicker");
    //  //var format = 'mm/dd/yy';
    //
    //  $("#en_fixedpicker").datepicker({
    //    altField: "#en_flexpicker",
    //    dateFormat: format,
    //    changeMonth: true,
    //    changeYear: true,
    //    yearRange: "1700:" + n
    //  });
    //  //dateInput.datepicker({dateFormat: format});
    //  //dateInput.datepicker('setDate', $.datepicker.parseDate(format, dateInput.val()));
    //}

    ////if ($("#st_fixedpicker").length) {
    ////  $("#st_fixedpicker").datepicker({dateFormat: format, changeMonth: true, changeYear: true, yearRange: "1700:" + year});
    ////  dateInput = $("#st_flexpicker");
    ////  dateInput.val(today.toLocaleDateString());
    ////  dateInput.datepicker("onSelect",  dateInput);
    ////  //dateInput.datepicker('setDate', $.datepicker.parseDate(format, dateInput.val()));
    ////}
    //
    set_control($("#st_fixedpicker"), $("#st_flexpicker"), format, year, today);
    //
    ////if ($("#en_fixedpicker").length) {
    ////  $("#en_fixedpicker").datepicker({dateFormat: format, changeMonth: true, changeYear: true, yearRange: "1700:" + year});
    ////  dateInput = $("#en_flexpicker");
    ////  dateInput.val(today.toLocaleDateString());
    ////  //dateInput.datepicker('setDate', $.datepicker.parseDate(format, dateInput.val()));
    ////}
    //
    set_control($("#en_fixedpicker"), $("#en_flexpicker"), format, year, today);

    //$("#st_fixedpicker").click(function (event) {
    //  $("#st_flexpicker").val($("#st_fixedpicker").datepicker("getDate"));
    //});
    //
    //$("#en_fixedpicker").click(function (event) {
    //  $("#en_flexpicker").val($("#en_fixedpicker").datepicker("getDate"));
    //});

    function set_control(control, input, format, year, today) {
      if (control.length) {
        control.datepicker({
          altField: input,
          dateFormat: format,
          changeMonth: true,
          changeYear: true,
          yearRange: "1700:" + year
        });
        //input.val(today);
      }
    }

    $("#st_flexpicker").change(function (event) {
      $.get('set_date', $("#set_date_form").serialize(), function (local_data) {
          $("#date_count").text(local_data.html);
          //$("#graph_frame").html(local_data.chart);
          }, 'json'  // I expect a json response
        );
        event.preventDefault();
      }
    );

    $("#en_flexpicker").change(function (event) {
      $.get('set_date', $("#set_date_form").serialize(), function (local_data) {
          $("#date_count").text(local_data.html);
          //$("#graph_frame").html(local_data.chart);
          }, 'json'  // I expect a json response
        );
        event.preventDefault();
      }
    );

  }
};


$(document).ready(_init_map_table);
$(document).on('page:load', _init_map_table);

