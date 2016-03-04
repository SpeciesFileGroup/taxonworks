$(document).ready(function() {
  if($("#show").length) {
    show();
  }
});

function show() {
  $('.section[data-menu="annotate"]').hover( function() {
    $(this).children().next().toggle(250);
  });   


$( "[view-bottom]" ).click(function() {
  $("[data-view='development']").toggle();
});

if ($('[data-menu="task"]').children().length < 1 ) {
  $('[data-menu="task"]').parent().addClass("disable");
}

if ($('[data-menu="add"]').children().length < 1 ) {
  alert();
  $('[data-menu="add"]').parent().addClass("disable");
}


  Mousetrap.bind('left', function() {
      if(typeof $(".navigation-item[data-arrow-back] a").attr('href') != "undefined") {
       location.href = $(".navigation-item[data-arrow-back] a").attr('href');
    }
  });

  Mousetrap.bind('right', function() {
    if(typeof $(".navigation-item[data-arrow-next] a").attr('href') != "undefined") {
      location.href = $(".navigation-item[data-arrow-next] a").attr('href');
    }
  });    
}