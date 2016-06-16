$(document).ready(function() {
  if($("#tasks").hasClass("current_hub_category")) {
    initTaskCarrousel();
  }
});

function initTaskCarrousel() {

  if($(window).width() > 1500) {
    task_column = 3;
  }
  else {
    task_column = 2;
  }

  var 
  task = new CarrouselTask("#task_carrousel", task_column, task_column);
  restartCarrouselTask(task);

  function restartCarrouselTask(element) {
    element.addFilter("source");
    element.addFilter("collecting_event");
    element.addFilter("collection_object");
    element.addFilter("taxon_name");
    element.addFilter("biology");
    element.resetView();
    element.filterChilds();
    element.showChilds();      
  }

  $('#filter').on('click', '[data-filter-category]', function() {
    if($(this).attr("data-filter-category") == "reset") {
      restartCarrouselTask(task);
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

  $('.more_tasks_nav').on('click',  function() {
    task.loadingDown();
    task.changeSelectedNavList(task.arrayPos);
  });  

  $('.task-nav-list').on('click', '.task-nav-item', function() {
    itemID = $(this).index();
    task.resetView();
    task.showChilds(itemID);
  });
  //Mousetrap Keys
  Mousetrap.bind('left', function() {
    task.loadingUp();
  });
  Mousetrap.bind('right', function() {
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
