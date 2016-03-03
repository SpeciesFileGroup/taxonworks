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
      task.resetView();
      task.filterChilds();
      task.showChilds();
    }
    else {
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