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
    TW.workbench.keyboard.createShortcut("alt+left", "Go to previous", "Taxon names browse", function() {
      if($('[data-button="back"]').is('a')) {
        document.querySelector('[data-button="back"]').click();
      }
    });

    TW.workbench.keyboard.createShortcut("alt+right", "Go to next", "Taxon names browse", function() {
      if($('[data-button="next"]').is('a')) {
        document.querySelector('[data-button="next"]').click();
      }
    });
    TW.workbench.keyboard.createShortcut((navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt') + '+p', "Pinboard", "Add to pinboard", function() {
      var element = document.querySelector('.pin-button') || document.querySelector('.unpin-button');
      if (element) {
        element.click();
      }
    });
    /*
    TW.workbench.keyboard.createShortcut(getOSKey + "up", "Go to ancestor", "Taxon names browse", function() {
      if($('[data-arrow="back"]').is('a')) {
        location.href = $('[data-arrow="ancestor"]').attr('href');
      }
    });

    TW.workbench.keyboard.createShortcut("down", "Go to descendant", "Taxon names browse", function() {
      if($('[data-arrow="descendant"]').is('a')) {
        location.href = $('[data-arrow="descendant"]').attr('href');
      }
    });
    */
  },

  isEmpty: function( el ){
    return !$.trim(el.html())
  }  
});


$(document).on('turbolinks:load', function() {
  if($("#show").length || $("#browse-view").length) {
    TW.views.shared.show.init();
  }
});