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
    element.resetFilters();
  }

  function resetFilters() {
    task.resetFilters();
    $('.reset-all-filters').fadeOut(0);
  }  

  $('.reset-all-filters').on('click', function() {
    resetFilters(); 
  });

  function resetStatusFilter() {
      task.setFilterStatus("data-category-prototype",false);
      task.setFilterStatus("data-category-unknown",false);
      task.setFilterStatus("data-category-stable",false);
      task.setFilterStatus("data-category-complete",false);                     
  }

  $('#search-filter').keyup( function() {
    var
      chain = $(this).val();
      task.filterKeys(chain);                 
  });  

  function updateFilter() {
      task.filterChilds(); 
      task.refresh();
  }

  $('#filter .switch input').on('click', function() {
    if(!$(this).is(':checked')) {
      resetStatusFilter();
      updateFilter();
    }
  });  


  $('#filter .filter-category [data-filter-category]').on('click', function() {
    if($(this).hasClass("activated")) {
      resetStatusFilter();
    }
  }); 

  $('#filter').on('click', '[data-filter-category]', function() {
    if($(this).attr("data-filter-category") == "reset") {
      task.resetFilters();
    }
    else {
      task.changeFilter("data-category-"+ $(this).attr("data-filter-category"));
    }
    if(task.empty()) {
      $('.reset-all-filters').fadeIn();
    }
    else {
      $('.reset-all-filters').fadeOut(0);
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

  //Keyboard Shortcuts
  createShortcut("left","Show previous card tasks", "Hub tasks", function() {
    task.loadingUp();
  });
  createShortcut("right","Show next card tasks", "Hub tasks", function() {
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
