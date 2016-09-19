var _init_map_table;

_init_map_table = function init_map_table() {

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
    //var geo_id = $("input[name='[geographic_area_id]']").val();
    $.get('set_area', $("input[name='[geographic_area_id]']").serialize(), function (local_data) {
        var popcorn = local_data;
        $("#area_count").text(local_data.html);
      }, 'json'  // I expect a json response
    );

    $("#set_area").on("ajax:success", function (e, data) {
        $("#area_count").text(data.html);
        return true;
      }
    ).on("#ajax:errror", function (e, xhr, status, error) {
        $("area_count").text("<p>set_area error => " + error + "</p>")
      }
    );
    event.preventDefault();
    }
  );
  //event.preventDefault();

};

$(document).ready(_init_map_table);
$(document).on('page:load', _init_map_table);

