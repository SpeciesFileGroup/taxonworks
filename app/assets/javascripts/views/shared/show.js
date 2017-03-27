var TW = TW || {};
TW.views = TW.views || {};
TW.views.shared = TW.views.shared || {};
TW.views.shared.show = TW.views.shared.show || {};

Object.assign(TW.views.shared.show, {
  init: function() {

    var
      that = this;

    $("[view-bottom]").click(function() {
      $("[data-view='development']").toggle();
    });

    $('.menu-drop').each( function() {
      if($(this).find('a').length < 1) {
        $(this).addClass("disable");
      }
    });

    $('[data-arrow]').each( function() {
      if($(this).is('span')) {
        $(this).addClass("disable");
      }
    });

    if(!$('#validation-panel li').length) {
      $('#validation-panel').hide();
    }  

    $('.panel').each( function() {
      if($(this).find('.information-panel').length) {
        if(that.isEmpty($(this).find('.information-panel'))) {
          $(this).find('.information-panel').parent().parent().hide();
        }
      }
    }); 
    this.bindShortcut();      
  },

  bindShortcut: function() {
    TW.workbench.keyboard.createShortcut("left", "Go to previous", "Taxon names browse", function() {
      if($('[data-arrow="back"]').is('a')) {
        location.href = $('[data-arrow="back"]').attr('href');
      }
    });

    TW.workbench.keyboard.createShortcut("right", "Go to next", "Taxon names browse", function() {
      if($('[data-arrow="next"]').is('a')) {
        location.href = $('[data-arrow="next"]').attr('href');
      }
    });    

    TW.workbench.keyboard.createShortcut("up", "Go to ancestor", "Taxon names browse", function() {
      if($('[data-arrow="back"]').is('a')) {
        location.href = $('[data-arrow="ancestor"]').attr('href');
      }
    });

    TW.workbench.keyboard.createShortcut("down", "Go to descendant", "Taxon names browse", function() {
      if($('[data-arrow="descendant"]').is('a')) {
        location.href = $('[data-arrow="descendant"]').attr('href');
      }
    });
  },

  isEmpty: function( el ){
    return !$.trim(el.html())
  }  
});

$(document).ready(function() {
  if($("#show").length) {
    var init_show = TW.views.shared.show;
    init_show.init();
  }
});