$(document).on('turbolinks:load', function() {
  if($(".easyzoom").length) {
    images();
  }
});

function images() {
    var $easyzoom = $('.easyzoom').easyZoom();

 //   $('.easyzoom').on('click', function() {
 //    location.href = ($(this).children('a').attr('href'));
 //   });
}
