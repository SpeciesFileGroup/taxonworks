var TW = TW || {};
TW.views = TW.views || {};
TW.views.hub = TW.views.hub || {};
TW.views.hub.favorites = TW.views.hub.favorites || {};

Object.assign(TW.views.hub.favorites, {
  init: function () {
    $('.task-section .unfavorite_link').on('click', function (element) {
      $(this).closest(".task_card").remove()
    })
    $('.data_section .unfavorite_link').on('click', function (element) {
      $(this).closest(".card-container").remove()
    })
  },
});

$(document).on('turbolinks:load', function () {
  if ($("#favorite-page").length) {
    TW.views.hub.favorites.init();
  }
});