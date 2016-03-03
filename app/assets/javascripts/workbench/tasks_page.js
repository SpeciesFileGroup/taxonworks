$(document).ready(function() {
  if($("#task_carrousel").length) {
    initTaskCarrousel();
  }
});

function initTaskCarrousel() {

  var 
    task = new carrouselTask("#task_carrousel",3,1);
    task.addFilter("source");
    task.addFilter("collecting_event");
    task.addFilter("collection_object");
    task.addFilter("taxon_name");
    task.resetView();
    task.filterChilds();
    task.showChilds();

  $('#filter').on('click', '[data-filter-category]', function() {
    if($(this).attr("data-filter-category") == "reset") {
      task.setFilterStatus("taxon_name",false);
      task.setFilterStatus("collecting_event",false);
      task.setFilterStatus("collection_object",false);
      task.setFilterStatus("source",false);
      deactivateBackgroundColorLink('[data-filter-category="source"]');
      deactivateBackgroundColorLink('[data-filter-category="taxon_name"]');
      deactivateBackgroundColorLink('[data-filter-category="collecting_event"]');
      deactivateBackgroundColorLink('[data-filter-category="collection_object"]');      
      activateBackgroundColorLink('[data-filter-category="reset"]');
      task.resetView();
      task.filterChilds();
      task.showChilds();
      setTimeout( function() {
      deactivateBackgroundColorLink('[data-filter-category="reset"]');
    }, 100);
    }
    else {
      changeBackgroundColorLink('[data-filter-category="'+ $(this).attr("data-filter-category") +'"]');
      task.changeFilter($(this).attr("data-filter-category"));
      task.resetView();
      task.filterChilds();
      task.showChilds();
    }
  });
  $('.navigation').on('click', 'a', function() {
      if($(this).attr('data-arrow') == "down") {
        task.loadingDown();
      } 
      else {
        task.loadingUp();
      }
  }); 
  //Mousetrap Keys
  Mousetrap.bind('up', function() {
    task.loadingUp();
  });
  Mousetrap.bind('down', function() {
    task.loadingDown();
  });  
  Mousetrap.bind('s', function() {
      changeBackgroundColorLink('[data-filter-category="source"]');
      task.changeFilter("source");
      task.resetView();
      task.filterChilds();
      task.showChilds(); 
  });
  Mousetrap.bind('e', function() {
      changeBackgroundColorLink('[data-filter-category="collecting_event"]');
      task.changeFilter("collecting_event");
      task.resetView();
      task.filterChilds();
      task.showChilds();    
  });
  Mousetrap.bind('o', function() {
      changeBackgroundColorLink('[data-filter-category="collection_object"]');
      task.changeFilter("collection_object");
      task.resetView();
      task.filterChilds();
      task.showChilds();   
  });  
  Mousetrap.bind('t', function() {
      changeBackgroundColorLink('[data-filter-category="taxon_name"]');
      task.changeFilter("taxon_name");
      task.resetView();
      task.filterChilds();
      task.showChilds();   
  });  
var      
  isSafari = isSafari = /Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor),
  last_time = new Date(),
  lastMove = 0,
  actualMove = 0;
  $("#task_carrousel").mousewheel(function(objEvent, intDelta) {   
      var now = new Date(),
      actualMove = objEvent.deltaY;
      
      if((now - last_time) >= 400)
      { 
        if (intDelta <= 0) { 
          if((actualMove < lastMove) || ((actualMove == lastMove) && isSafari)) {
            task.loadingUp();
            last_time = new Date();
            }
          }
          else {
            if((actualMove > lastMove) || ((actualMove == lastMove) && isSafari)) {
              task.loadingDown();
              last_time = new Date();
            }
          }     
      }     
      lastMove = actualMove;
  });
}