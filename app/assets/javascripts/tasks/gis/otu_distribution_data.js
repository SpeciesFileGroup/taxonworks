var _init_otu_distribution_data_widget;

_init_otu_distribution_data_widget = function init_otu_distribution_data() {
  if ($('#otu_distribution_widget').length) {
    if (document.getElementById('_displayed_distribution_form') != null) {
      var newfcdata = $("#_displayed_distribution_form");
      var fcdata = newfcdata.data('feature-collection');
      var map_canvas = newfcdata.data('map-canvas');
      var otu_map = initializeComplexMap(map_canvas, fcdata);
      //add_map_listeners();
      $('input[type="checkbox"]').change(function () {
        initializeComplexMap(map_canvas, newfcdata.data('feature-collection'));
      });
    }
  }
};
$(document).ready(_init_otu_distribution_data_widget);
$(document).on("page:load", _init_otu_distribution_data_widget);
