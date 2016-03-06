$(document).ready(function() {
  if($("table").length) {
    list();
  }
});

function list() {
var
  animationTime = 250;

function showAll() {
    $('th, td').show(animationTime);
    $('.table-options').hide();
    $('[data-filter-active]').attr("data-filter-active","true");
    $('[data-group]').children('a').attr("data-icon","show");
  }
  $('.navigation-controls').on('click', '[showAll]', function() {
    showAll();
  });  

  $('.navigation-controls').on('click', '[data-group]', function() {
    if($(this).attr("data-filter-active") === "true") {
      $('table [data-group="' + $(this).attr("data-group") + '"]').hide(animationTime);
      $(this).attr("data-filter-active","false");
      $(this).children('a').attr("data-icon","hide");
    }
    else {
      $('table [data-group="' + $(this).attr("data-group") + '"]').show(animationTime);
      $(this).children('a').attr("background-image","/assets/icons/show.svg");
      $(this).children('a').attr("data-icon","show");
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
        $("table").tablesorter({ 
        widgets: ['zebra'] 
        }); 
    } 
);

 function initContextMenus() {
  $.contextMenu('destroy', ".contextMenuCells" );
        $.contextMenu({
            selector: '.contextMenuCells', 
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
  $.contextMenu('destroy', "thead th" );
        $.contextMenu({
            selector: 'thead th', 
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
