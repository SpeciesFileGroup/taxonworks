$(document).ready(function() {
  if($("table").length) {
    list();
  }
});

function list() {
var
  animationTime = 250;


$('.tooltip').tooltipster({
   animation: 'fade',
   delay: 200,
   position: 'bottom',
   theme: 'tooltipster-default',
   touchDevices: false,
   trigger: 'hover'
});

$('.tooltip-help').tooltipster({
  animation: 'fade',
  delay: 200,
  position: 'bottom',
  content: $('<div class="tooltip-help-box separate-left separate-right"><h2 data-icon="help">List information</h2><hr><h3><span class="small-icon" data-icon="arrow-right">Column header</span></h3><span><b>Click</b> on the column header <b>to sort records</b> from highest to lowest, making <b>right click</b> on them it will <b>open a context menu</b> to hide them.</span><h3 class="small-icon" data-icon="arrow-right"><span>List records</span></h3><span>Make <b>double click</b> on a record to <b>show it</b>.<br> Doing <b>right click</b> on it, will <b>open a context menu</b> with a few options.<h3 class="small-icon" data-icon="arrow-right">Shortcuts</h3> Use the left and right keyboard arrows to navigate on the pages</span><h3 class="small-icon" data-icon="arrow-right">Display</h3> Click on the buttoms to hide or show columns groups</span></div>')
});


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
    $.each($('table th[data-group="' + $(this).attr("data-group") + '"]'), function( key, value ) {
      toggleColumn($(value));
    });
    if($(this).attr("data-filter-active") === "true") {      
      $(this).attr("data-filter-active","false");
      $(this).children('a').attr("data-icon","hide");
    }
    else {
      $(this).attr("data-filter-active","true");
      $(this).children('a').attr("data-icon","show");
    }
  }); 


var 
  
  dataList = $.grep($('table th').map(function() {
      return $(this).attr("data-group");
    }), 
    function(value) {
      return value != 'null';
  });  

displayList = unique(dataList);

if(displayList.length > 0) {
  $('.panels-container').append(createDivDisplay());
}




function createDivDisplay() {
    var
      injectionHtml = ('<div id="displayOptions" class="panel column-small separate-left" data-help="Click on the buttoms to show or hide columns groups."><div class="title action-line">Display<div class="small-icon reset" data-filter-active="true" showAll data-icon="reset">Reset</div></div><div class="navigation-controls">');
      $.each(displayList, function(i, value) {
        injectionHtml += createOptionDisplay(value);
      });
      injectionHtml += ('</div></div>');
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
  if($(this).find("[data-show] a").length > 0) {
    location.href = $(this).find("[data-show] a").attr("href");
  }
});

function toggleColumn(elementObject) {
  $(elementObject.parents('table').find('td:nth-child('+ ($(elementObject).index()+1)+ ')')).toggle(250);
  $(elementObject.parents('table').find('th:nth-child('+ ($(elementObject).index()+1)+ ')')).toggle(250);
}


  Mousetrap.bind('left', function() {
    if($('.page-navigator a[rel="previous"]').length > 0) {
      location.href = $('.page-navigator a[rel="previous"]').attr('href');
    }
  });

  Mousetrap.bind('right', function() {
    if($('.page-navigator a[rel="next"]').length > 0) {
      location.href = $('.page-navigator a[rel="next"]').attr('href');
    }
  });  

$(document).ready(initContextMenus);
$(document).on('page:change', initContextMenus);
$(document).ready(headerTableOptions);
$(document).on('page:change', headerTableOptions);
$(document).ready(orderLists);
$(document).on('page:load', orderLists);

function orderLists() { 
        $("table").tablesorter({ 
        widgets: ['zebra'] 
        }); 
    } 

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
                    toggleColumn(options.$trigger);
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
