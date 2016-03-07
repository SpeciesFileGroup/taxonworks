$(document).ready(function() {
  if($("table").length) {
    list();
  }
});

function list() {
var
  animationTime = 250;

function showAll() {
    $('th, td').not('.table-options').show(animationTime);
    $('[data-filter-active]').attr("data-filter-active","true");
    $('[data-group]').children('a').attr("data-icon","show");
  }
  $('div').on('click', '.reset[showAll]', function() {
    showAll();
  });  


  $('div').on('click','#displayOptions .navigation-item[data-group]', function(event) {
    event.stopImmediatePropagation();
    if($(this).attr("data-filter-active") === "true") {
      $('table [data-group="' + $(this).attr("data-group") + '"]').hide(animationTime);
      $(this).attr("data-filter-active","false");
      $(this).children('a').attr("data-icon","hide");
    }
    else {
      $('table [data-group="' + $(this).attr("data-group") + '"]').show(animationTime);
      $(this).attr("data-filter-active","true");
      $(this).children('a').attr("data-icon","show");
    }
  }); 


var 
  dataList = $('table td').map(function() {
    return $(this).attr("data-group");
  });

displayList = unique(dataList);

if(displayList.length > 0) {
  $('.panels-container').append(createDivDisplay());
}

function createDivDisplay() {
    var
      injectionHtml = ('<div id="displayOptions" class="panel column-small"><div class="title action-line">Display<div class="small-icon reset" data-filter-active="true" showAll data-icon="reset">Reset</div></div><div class="navigation-controls">');
      $.each(displayList, function(i, value) {
        injectionHtml += createOptionDisplay(value);
      });
      injectionHtml += ('<div class="navigation-item" class="small-icon" data-filter-active="true" showAll><a data-icon="reset">Show all</a></div></div></div>');
      return injectionHtml;
  }  


function createOptionDisplay(value) {
  return ('<div class="navigation-item" data-group="'+ value + '" data-filter-active="true"><a data-icon="show">'+ value + '</a></div>')
}


function unique(list) {
    var result = [];
    $.each(list, function(i, e) {
        if ($.inArray(e, result) == -1) result.push(e);
    });
    return result;
}



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
