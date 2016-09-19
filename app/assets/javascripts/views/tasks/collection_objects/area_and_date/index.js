var _init_map_table;

_init_map_table = function init_map_table() {
  if ($("#set_area_form").length) {
    var result_map;  // intended for use to display on a map objects which know how to GeoJSON themselves

    $(".result_map_toggle").click(function (event) {           // switch to the map
      $("#show_list").attr('hidden', true);         // hide the area selector
      $("#show_map").removeAttr('hidden');          // reveal the map
      $(".result_list_toggle").removeAttr('hidden');           // expose the other link
      $(".result_map_toggle").attr('hidden', true);
      $("[name='[geographic_area_id]']").attr('value', '');
      result_map = _init_simple_map();
    });

    $(".result_list_toggle").click(function (event) {          // switch to the area by name selector
      $("#show_map").attr('hidden', true);          // hide the map
      $("#show_list").removeAttr('hidden');         // reveal the area selector
      $(".result_map_toggle").removeAttr('hidden');            // expose the other link
      $(".result_list_toggle").attr('hidden', true);
      $("#drawn_area_shape").attr('value', '');
    });

    $("#set_area").click(function (event) {      // register the click handler for the made-from-scratch-button
        $("#area_count").text('**********');
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
      $("#result_span").text('**********');
      $.get('find', $("#set_area_form").serialize(), function (local_data) {
        var popcorn = local_data;
        var html = local_data.html;
        $("#show_list").html(html);
        if (local_data.feature_collection) {
          $("#show_map").removeAttr('hidden');
          result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', local_data.feature_collection);
        }
        }, 'json'  // I expect a json response
      );
      event.preventDefault();
    })
  }
};

$(document).ready(_init_map_table);
$(document).on('page:load', _init_map_table);

