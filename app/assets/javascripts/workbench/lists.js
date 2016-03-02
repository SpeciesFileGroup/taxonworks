$(document).ready(function() {
  if($("#list").length) {
    list();
  }
});

function list() {
var
  animationTime = 250;

function showAll() {
    $('th, td').show(animationTime);
    $('.table-options').hide();
    $('[data-filter-publication]').attr("data-filter-publication","true");
    $('[data-filter-metadata]').attr("data-filter-metadata","true");
    $('[data-filter-user-info]').attr("data-filter-user-info","true");
    $('[data-group] img').attr("src","/assets/icons/show.svg");
  }
  $('.navigation-controls').on('click', '[data-display="showAll"]', function() {
    showAll();
  });  

  $('.navigation-controls').on('click', '.navigation', function() {
    if($(this).attr("data-filter-active") === "true") {
      $('table [data-group="' + $(this).attr("data-group") + '"]').hide(animationTime);
      $(this).attr("data-filter-active","false");
      $(this).children('img').attr("src","/assets/icons/hide.svg");
    }
    else {
      $('table [data-group="' + $(this).attr("data-group") + '"]').show(animationTime);
      $(this).children('img').attr("src","/assets/icons/show.svg");
      $(this).attr("data-filter-active","true");
    }
  }); 




$("tbody tr").dblclick(function() {
  location.href = $(this).find("[data-show] a").attr("href");
});

function removeColumn(elementObject) {
  $(elementObject.parents('table').find('td:nth-child('+ ($(elementObject).index()+1)+ ')')).hide(250);
  $(elementObject.parents('table').find('th:nth-child('+ ($(elementObject).index()+1)+ ')')).hide(250);
}

$(document).ready(initContextMenus);
$(document).on('page:change', initContextMenus);
$(document).ready(headerTableOptions);
$(document).on('page:change', headerTableOptions);


$(document).ready(function() 
    { 
        $("#list").tablesorter({ 
        widgets: ['zebra'] 
        }); 
    } 
);

 function initContextMenus() {
  $.contextMenu('destroy', ".context-menu-one" );
        $.contextMenu({
            selector: '.context-menu-one', 
            autoHide: true,
            callback: function(key, options) {
                var m = "clicked: " + key;

                switch(key) {
                  case "show":
                    location.href = $(this).find("[data-show] a").attr('href');
                  break;
                  case "edit":
                    location.href = $(this).find("[data-edit] a").attr('href');
                  break;                  
                  case "delete":
                    $(this).find("[data-delete] a").click();
                  break;
                }
            },
            items: {
                "show": {name: "Show", icon: "show"},
                "sep1": "---------",
                "edit": {name: "Edit", icon: "edit"},
                "delete": {name: "Delete", icon: "delete"}
            }
        });
  }

 function headerTableOptions() {
  $.contextMenu('destroy', ".headerTableOptions" );
        $.contextMenu({
            selector: '.headerTableOptions', 
            autoHide: true,
            callback: function(key, options) {
                var m = "clicked: " + key;

                switch(key) {              
                  case "delete":
                    removeColumn(options.$trigger);
                  break;
                  case "show":
                    showAll(options.$trigger);
                  break;
                }
            },
            items: {                
                "delete": {name: "Delete", icon: "delete"},
                "sep1": "---------",
                "show":{name: "Show All", icon: "show"}
            }
        });
  }  
  }