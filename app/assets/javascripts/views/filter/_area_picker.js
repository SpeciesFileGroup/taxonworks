var TW = TW || {};                      // TW "namespacing" object
TW.views = TW.views || {};            // mimic directory structure in app/assets/javascripts
TW.views.filter = TW.views.filter || {};
TW.views.filter.area_picker = TW.views.filter.area_picker || {};

Object.assign(TW.views.filter.area_picker, {

//
// Initialize the widget
//
  initialize_area_picker: function (form, area_type) {
    // turn the input into an jQuery autocompleter
    // https://jqueryui.com/autocomplete/
    //
    // all of these should likely be renamed for namespacing purposes
    this.initialize_autocomplete(form);
    // this.bind_new_link(form);
    // this.bind_switch_link(form);
    // this.bind_expand_link(form);
    // this.bind_label_mirroring(form);
    this.bind_remove_links(form.find('.remove_area'));

    // this.make_list_sortable(form);
    // this.bind_position_handling_to_submit_button(form);
    this.bind_definition_listener(form);
  },

// Empties search text box and hide new_person div
  clear_area_picker: function (form) {
    var area_picker;
    area_picker = form.find('.area_picker_autocomplete');
    $(area_picker).val("");
    // form.find(".new_area").attr("hidden", true);
  },

  initialize_autocomplete: function (form) {
    var autocomplete_input = form.find(".area_picker_autocomplete");
    autocomplete_input.autocomplete({
      source: '/geographic_areas/autocomplete',
      appendTo: autocomplete_input.parent(),
      open: function (event, ui) {
        TW.views.filter.area_picker.bind_hover(form);
      },
      select: function (event, ui) {    // execute on select event in search text box
        TW.views.filter.area_picker.insert_existing_area(form, ui.item.id, ui.item.label_html);
        TW.views.filter.area_picker.clear_area_picker(form);
        //   TW.views.filter.area_picker.make_list_sortable(form);     // was this inadvertantly lost?
        return false;
      }

    }).autocomplete("instance")._renderItem = function (ul, item) {
      return $("<li class='area'>")
        .append("<a>" + item.label + ' <span class="hoverme" data-area-label_html="' + item.label_html + '" + data-geographic_area_id="' + item.id + '">...</span></a>')
        .appendTo(ul);
    };
  },
  //
  // make_list_sortable: function (form) {
  //   var list_items = form.find(".area_list");
  //   list_items.sortable({
  //     change: function (event, ui) {
  //       if ($('form[id^="new_"]').length == 0) {
  //         TW.views.filter.area_picker.warn_for_save(form.find(".area_picker_message"));
  //       }
  //     }
  //   });
  //   list_items.disableSelection();
  // },

// bind a hover event to an ellipsis
  bind_hover: function (form) {
    var hiConfig = {
      sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)
      interval: 400, // number = milliseconds for onMouseOver polling interval
      timeout: 200, // number = milliseconds delay before onMouseOut
      over: function () {
        var this_area_hover;
        this_area_hover = $(this);   // modified to not do AJAX call, but use attribute already extant
        this_area_hover.html('... ' + this_area_hover.data('area-label_html'));
      }, // function = onMouseOver callback (REQUIRED)
      out: function () {
        this.textContent = '...';   // how weird is this this?
      } // function = onMouseOut callback (REQUIRED)
    };
    $('.hoverme').hoverIntent(hiConfig);
  },

  // bind_position_handling_to_submit_button: function (form) {
  //   // var base_class = form.data('base-class');
  //   var base_class = 'areagable_object';
  //
  //   form.closest("form").find('input[name="commit"]').click(function () {
  //     var i = 1;
  //     var area_index;
  //     form.find('.area_item').each(function () {
  //       console.log($(this));
  //       area_index = $(this).data('area-index');
  //       $(this).append(
  //         $('<input hidden name="' + base_class + '[areas_attributes][' + area_index + '][position]" value="' + i + '" >')
  //       );
  //       i = i + 1;
  //     });
  //   });
  // },

  insert_existing_area: function (form, area_id, label) {
    var base_class;// = form.data('base-class');
    base_class = 'area_object';
    var random_index = new Date().getTime();
    var area_list = form.find(".area_list");

    // insert visible list item
    area_list.append($('<li class="area_item" data-area-index="' + random_index + '">')
      .append(label).append('&nbsp;')
      .append(TW.views.filter.area_picker.remove_link())
      // nest hidden geographic_area_id in <li>
      .append($('<input hidden name="' + base_class + '[geographic_area_ids][]" value="' + area_id + '" >'))
    );
  },

//
// Binding actions (clicks) to links
//
  bind_new_link: function (form) {
    // Add a citation_topic to the list via the add new form
    form.find("#area_picker_add_new").click(function () {
      TW.views.filter.area_picker.insert_new_area(form);
      // form.find('.new_area').show(); // attr("hidden", true);
      TW.views.filter.area_picker.clear_area_picker(form);
    });
  },


  bind_definition_listener: function (form) {
    form.find(".definition").keyup(function () {
      var d = form.find(".definition").val();

      if (d.length == 0) {
        $("#area_picker_add_new").hide();
      }
      else {
        $("#area_picker_add_new").css("display", "flex");
      }
    })
  },

  // insert_new_area: function (form) {
  //   var base_class = 'areagable_object';
  //   var random_index = new Date().getTime();
  //   var area_base = base_class + '[filter_attributes][' + random_index + '][keyword_attributes]';
  //   var area_list = form.find(".area_list");
  //
  //   var name = form.find('.keyword_picker_autocomplete').val();
  //
  //   area_list.append($('<li class="area_item" data-new-area="true" data-area-index="' + random_index + '" >')
  //     .append(name + "&nbsp;")
  //     .append(TW.views.filter.area_picker.remove_link())
  //     .append($('<input hidden name="' + area_base + '[name]" value="' + name + '" >'))
  //     .append($('<input hidden name="' + area_base + '[definition]" value="' + form.find(".definition").val() + '" >')));
  //
  //   $(".keyword_picker_form").hide();
  // },

  remove_link: function () {
    var link = $('<a href="#" class="remove_area">remove</a>');
    TW.views.filter.area_picker.bind_remove_links(link);
    return link;
  },

  // bind_label_mirroring: function (form) {
  //   form.find(".keyword_picker_form input").on("change keyup", function () {
  //     form.find(".name_label").html(
  //       form.find(".name").val()
  //     );
  //   });
  // },

  bind_remove_links: function (links) {
    links.click(function () {
      var list_item = $(this).parent('li');
      var area_picker = list_item.closest('.area_picker');
      var area_id = list_item.data('area-id');
      var area_index = list_item.data('area-index');
      var base_class = 'area_object';
      // var base_class = tag_picker.data('base-class');

      if (area_id != undefined) {
        var area_list = list_item.closest('.area_list');

        // if this is not a new area
        // if (list_item.data('new-person') != "true")  {
        // if there is an ID from an existing item add the necessary (hidden) _destroy input
        area_list.append($('<input hidden name="' + base_class + '[areas_attributes][' + area_index + '][geographic_area_id]" value="' + area_id + '" >'));
        area_list.append($('<input hidden name="' + base_class + '[areas_attributes][' + area_index + '][_destroy]" value="1" >'));

        // Provide a warning that the list must be saved to properly delete the records, tweak if we think necessary
        TW.views.filter.area_picker.warn_for_save(area_list.siblings('.area_picker_message'));
        // }
      }
      list_item.remove();
    });
  },

  warn_for_save: function (msg_div) {
    msg_div.addClass('warning');
    msg_div.html('Update areas click required to confirm removal/reorder of area item.');
  }

});

var _initialize_area_picker_widget;

_initialize_area_picker_widget = function
  init_area_picker() {
  $('.area_picker').each(function () {
    TW.views.filter.area_picker.initialize_area_picker($(this));
  });
};

// Initialize the script on page load
$(document).ready(_initialize_area_picker_widget);

