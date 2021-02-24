var FilterHub = function () {

  this.task_column = ($(window).width() > 1500) ? 3 : 2;
  this.task_row = ($(window).width() > 1500) ? 4 : 3;
  this.arrayData = [];
  this.arrayTasks = [];
  this.that = this;
  this.handleEvents(this.that);
};

FilterHub.prototype.changeTaskSize = function (column, row) {
  this.arrayTasks.forEach(function (element) {
    element.changeSize(column, row);
  });
};

FilterHub.prototype.handleEvents = function (that) {
  $("#task_carrousel").each(function (i, element) {
    that.arrayTasks.push(new CarrouselTask("#" + $(element).attr("id"), that.task_row, that.task_column));
  });

  $("[data-section]").each(function (i, element) {
    that.arrayData.push(new CarrouselData($(element).attr("data-section"), 99, 0));
  });

  $(".task_card").on("keypress", function(e) {
    if(e.which == 13) {
      window.location.href = $(this).children("a").attr("href")
    }
  })

  $(".card-container").on("keypress", function(e) {
    if(e.which == 13) {
      window.location.href = $(this).children().children("a").attr("href")
    }
  })

  $('#search-filter').keyup(function (key) {
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') return
    var chain = $(this).val();

    [that.arrayData, that.arrayTasks].forEach(function (element) {
      element.forEach(function (element) {
        element.filterKeys(chain);
      });
    });
  });

  $('.reset-all-filters').on('click', function () {
    that.changeAllSectionsFilter(that.arrayData);
    that.changeAllSectionsFilter(that.arrayTasks);
  });

  //Keyboard Shortcuts
  TW.workbench.keyboard.createShortcut("left", "Show previous card tasks", "Hub tasks", function () {
    that.arrayTasks.forEach(function (element) {
      element.loadingUp();
    });
  });

  TW.workbench.keyboard.createShortcut("right", "Show next card tasks", "Hub tasks", function () {
    that.arrayTasks.forEach(function (element) {
      element.loadingDown();
    });
  });

  $('#filter [data-filter-category]').on('click', function () {
    var
      elementFilter = $(this).attr('data-filter-category');

    if($(this).parent().hasClass('filter-category') && !$(this).hasClass('activated')) {
      that.resetAllStatusCards()
    }
    if (elementFilter === "reset") {
      that.changeAllSectionsFilter(that.arrayData);
      that.changeAllSectionsFilter(that.arrayTasks);
    }
    else {
      [that.arrayData, that.arrayTasks].forEach(function (element) {
        element.forEach(function (element) {
          element.changeFilter("data-category-" + elementFilter);
        });
      });
    }
    if (that.allEmpty(that.arrayData) && that.allEmpty(that.arrayTasks)) {
      $('[data-section="Supporting"] .reset-all-filters').fadeIn();
    }
    else {
      $('.reset-all-filters').fadeOut(0);
    }
  });

  $('#filter .navigation-controls-type [data-filter-category]').on('click', function () {
    var elementFilter = $(this).attr('data-filter-category');
    var activated = $(this).hasClass('activated')

    $('#filter .navigation-controls-type .navigation-item').each(function () {
      $(this).removeClass('activated');
    });

    if (!activated) {
      $(this).addClass('activated')
    }

    if ($(this).hasClass('activated')) {
      that.resetTypeFilter();
    }

    that.resetTypeFilter();
    if ($(this).hasClass('activated')) {
      [that.arrayData, that.arrayTasks].forEach(function (element) {
        element.forEach(function (element) {
          element.changeFilter("data-category-" + elementFilter);
        });
      });
    }
  });

  $('#filter .switch input').on('click', function (element) {
    that.resetAllStatusCards()
  });
}

FilterHub.prototype.resetAllStatusCards = function() {
  var that = this;

  [that.arrayData, that.arrayTasks].forEach(function (element) {
    element.forEach(function (element) {
      that.resetStatusFilter();
      element.refresh();
    });
  });
}

FilterHub.prototype.resetStatusFilter = function () {
  [this.arrayData, this.arrayTasks].forEach(function (element) {
    element.forEach(function (element) {
      element.setFilterStatus("data-category-prototype", false);
      element.setFilterStatus("data-category-unknown", false);
      element.setFilterStatus("data-category-stable", false);
      element.setFilterStatus("data-category-complete", false);
    });
  });
}

FilterHub.prototype.resetTypeFilter = function () {
  [this.arrayData, this.arrayTasks].forEach(function (element) {
    element.forEach(function (element) {
      element.setFilterStatus("data-category-filters", false);
      element.setFilterStatus("data-category-browse", false);
      element.setFilterStatus("data-category-new", false);
    });
  });
}

FilterHub.prototype.changeAllSectionsFilter = function (arrayData) {
  arrayData.forEach(function (element) {
    $("#search-filter").val("");
    element.resetFilters();
    element.filterChildren();
    $('.reset-all-filters').fadeOut(0);
  });
}

FilterHub.prototype.allEmpty = function (arraySection) {
  var inc = 0;

  arraySection.forEach(function (element) {
    if (element.empty()) {
      inc++
    }
  });
  return (inc == arraySection.length);
}
