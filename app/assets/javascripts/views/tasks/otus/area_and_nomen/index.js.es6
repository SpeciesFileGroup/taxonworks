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

      $(".filter-button").on("click", function () {
        that.toggleFilter();
      });
    }
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
    
    if (($("#area_count").text() > 0) || ($("#nomen_count").text() > 0) || ($("#author_count").text() > 0) || ($("#verbatim_author_count").text() > 0)) {
      $("#find_area_and_nomen_commit").removeAttr("disabled");
    }
    else {
      $("#find_area_and_nomen_commit").attr("disabled", "disabled");
      $("#download_button").attr("disabled", "disabled");
    }
    this.cleanResults();
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
    $("#find_item").mx_spinner('show');
    $.get(href, this.serializeFields(), function (local_data) {
    });
    $("#download_button").removeAttr("disabled");
    
    event.preventDefault();
  }
});

$(document).on("turbolinks:load", function () {
  if ($("#otu_by_area_and_nomen").length) {
    let _init_map_table = TW.views.tasks.otus;
    _init_map_table.init();
  }
});
