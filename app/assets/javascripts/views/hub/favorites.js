var TW = TW || {};
TW.views = TW.views || {};
TW.views.hub = TW.views.hub || {};
TW.views.hub.favorites = TW.views.hub.favorites || {};

Object.assign(TW.views.hub.favorites, {
  init: function () {
    $('.unfavorite_link').on('click', function (element) {
      $(this).closest(".task_card").remove()
    })
  },
});

$(document).on('turbolinks:load', function () {
  if ($("#favorite-page").length) {
    TW.views.hub.favorites.init();
  }
});