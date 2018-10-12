var CarrouselTask = function (sec, rows, columns) {

    // sec = Name of data section, this is for identify div.
    // rows = This is for the number of rows that will be displayed, if this number is less than the number of items, it will activate the navigation controls

    this.childs = [];
    this.start = 0;
    this.middleBoxSize = 650;
    this.boxSize = 500;
    this.active = [];
    this.arrayPos = 0;
    this.childsCount = 0;
    this.isEmpty;
    this.sectionTag = "";
    this.filters = {};
    this.sectionTag = sec;
    this.that = this;
    this.filterWords = "";
    this.changeSize(columns,rows);
    this.handleEvents(this.that);
  };

  CarrouselTask.prototype.handleEvents = function(that) {
    $(this.sectionTag + ' .navigation').on('click', 'a', function() {
        if($(this).attr('data-arrow') == "down") {
          that.arrayTasks.forEach(function(element) {
            if($(this).attr('data-arrow') == "down") {            
              that.loadingDown();
          }
            else {
              that.loadingUp();
            }
        });
      }
    });

    $(this.sectionTag + ' .more_tasks_nav').on('click',  function() {
        that.loadingDown();
        that.changeSelectedNavList(element.arrayPos);
    });  

    $(this.sectionTag + ' .task-nav-list').on('click', '.task-nav-item', function() { 
        itemID = $(this).index();   
        that.resetView();
        that.showChilds(itemID);
    });

  }

  CarrouselTask.prototype.changeSize = function(maxColumns, maxRow) {
    this.changeTasks = maxRow;    
    this.maxRow = maxRow;
    this.maxCards = maxRow * maxColumns;
    this.maxColumns = maxColumns;    
    $(this.sectionTag).children(".task-section").css("width",((maxColumns*427.5) + "px"));
    if(maxRow < 99){
      $(this.sectionTag).children(".task-section").css("height",((maxRow*180) + "px"));
    }

    this.resetChildsCount();
    this.filterChilds();
    this.injectNavList();
    this.resetFilters();    
  };

  CarrouselTask.prototype.addFilter = function(nameFilter) {
    this.filters[nameFilter] = false;
  };

  CarrouselTask.prototype.empty = function() {
    return this.isEmpty;
  };

  CarrouselTask.prototype.refresh = function() {
    this.resetView();
    this.filterChilds();
    this.showChilds(); 
  };  

  CarrouselTask.prototype.resetFilters = function() {
    for (var key in this.filters) {
      this.filters[key] = false
    }   
    this.filterWords = "";
    this.refresh();    
  };

  CarrouselTask.prototype.injectNavList = function() {
    for(var i = 0; i < this.childsCount; i++) {
      if((i - this.maxCards >= 0) && (this.maxCards - i <= 0)) {
        $(this.sectionTag + " .task-nav-list").append('<div class="task-nav-item"></div>');
      }
      else {
        $(this.sectionTag + " .task-nav-list").append('<div class="task-nav-item active"></div>');
      }
    }
  };

  CarrouselTask.prototype.changeSelectedNavList = function(childIndex) {
    var
    count = this.maxCards;

    $(this.sectionTag + " .task-nav-list").empty();

    for(var i = 0; i < this.active.length; i++) {
      if((i >= childIndex) && (count > 0)) {
        $(this.sectionTag + " .task-nav-list").append('<div class="task-nav-item active"></div>');
        count--;
      }
      else {
        $(this.sectionTag + " .task-nav-list").append('<div class="task-nav-item"></div>');
      }
    }
  };

  CarrouselTask.prototype.checkChildFilter = function(childTag) {
    var find = 0;
    var isTrue = 0;

      for (var key in this.filters) {

        if(this.filters[key] == true) {
          find++;
          if ($(childTag).has("["+ key +"]").length) {
            isTrue++;
          }
        } 
      }
      if((isTrue == find) && (this.hasWords(childTag))) {
        return true;
      }
      else {
        return false;
      }  
     
  };

  CarrouselTask.prototype.filterKeys = function(handleKey) {
    this.filterWords = handleKey;
    this.refresh();
  }
  
  CarrouselTask.prototype.hasWords = function(child) {
    if(($(child).find('.task_name').text().toLowerCase().indexOf(this.filterWords.toLowerCase()) >= 0) || (this.filterWords == "")) {
      return true;
    }
    else {
      var words = this.filterWords.toLowerCase().trim().split(" ");
      for(var i = 0; i < words.length; i++) {
        if ($(child).find('.task_description').text().toLowerCase().indexOf(words[i]) >= 0) {
          return true;
        }
      }
      return false;
    }
  }
  
  CarrouselTask.prototype.checkEmpty = function() {
    var
      count = 0;

    for(var i = 0; i < this.childsCount; i++) {      
      child = $(this.sectionTag + ' .task_card:nth-child('+ i +')');
      if(!$(child).is(":visible")) {      
        count++;
      }
    }
    this.isEmpty = (count == this.childs ? true : false);
    this.noTaskFound();
  }  

  CarrouselTask.prototype.resetChildsCount = function() {
    this.childsCount = $(this.sectionTag + ' .task_card').length;
  };

  CarrouselTask.prototype.setFilterStatus = function(filterTag, value)  {
    this.filters[filterTag] = value;
  };

  CarrouselTask.prototype.changeFilter = function(filterTag)  {
    this.filters[filterTag] = !this.filters[filterTag];
    this.resetView();
    this.filterChilds();
    this.showChilds();
  };

  CarrouselTask.prototype.showChilds = function(childIndex) {
    var
    count = 0;

    if (typeof childIndex !== "undefined") {
      if(childIndex > this.active.length-this.maxCards) {
        childIndex = this.active.length-this.maxCards;
      }
      this.start = childIndex;
      this.changeSelectedNavList(childIndex);
      this.arrayPos = childIndex;
    }
    else {
      this.start = 0;
      this.changeSelectedNavList(this.start);
      this.arrayPos = 0;
    }
    for (var i = this.start; i < this.active.length; i++) {

      var child = $(this.sectionTag + ' .task_card:nth-child('+ this.active[i] +')');
      if(count < this.maxCards) {
        child.show(250);
        child.attr("tabindex", 0);
      }
      count++;
    }
    this.showMoreNav(((this.start + this.maxCards) <= this.active.length));
    if(count == 0) {
      this.isEmpty = true;
    }
    else {
      this.isEmpty = false;
    }
    this.noTaskFound();
  };

  CarrouselTask.prototype.noTaskFound = function(count) {
    if(this.isEmpty) {
      $(this.sectionTag + ' .no-tasks').fadeIn(250);
    }
    else {
      $(this.sectionTag + ' .no-tasks').fadeOut(250);
    }
  };

  CarrouselTask.prototype.filterChilds = function() {
    var
    find = 0,
    activeCount = 0;
    this.arrayPos = 0;
    this.active = [];
    this.childs = [];

    for (var i = 1; i <= this.childsCount; i++) {
      child = $(this.sectionTag + ' .task_card:nth-child('+ (i) +')');
      if(this.checkChildFilter(child)) {
        this.active[activeCount] = i;
        activeCount++;
        this.childs[i] = true;
        find++;
      }
    }
    this.navigation((find > this.maxCards));
    this.showMoreNav((find > this.maxCards));
  };

  CarrouselTask.prototype.resetView = function() {
    $(this.sectionTag + ' .task_card').css("display","none");
  };

  CarrouselTask.prototype.navigation = function(value) {
    if(value) {
      $(this.sectionTag + " .navigation a").show(250);
    }
    else {
      $(this.sectionTag + " .navigation a").hide(250);
    }
  };

  CarrouselTask.prototype.loadingDown = function() {
    var
    sectionTag = this.sectionTag,
    active = this.active,
    maxCards = this.maxCards,
    changeTasks = this.changeTasks;

    for(var i = 0; i < changeTasks; i++) {
      if(this.active.length > (this.arrayPos + this.maxCards )) {
        $(sectionTag + " .task_card:nth-child("+ active[(this.arrayPos)] +")" ).hide(0);
        $(sectionTag + " .task_card:nth-child("+ active[(this.arrayPos+this.maxCards)] +")" ).fadeIn(250);
        this.arrayPos++;
      }
    }
    this.changeSelectedNavList(this.arrayPos);
  };


  CarrouselTask.prototype.showMoreNav = function(value) {
    if(value) {
      $('.more_tasks_nav').fadeIn(250);
    }
    else {
      $('.more_tasks_nav').fadeOut(250);
    }
  };

  CarrouselTask.prototype.loadingUp = function() {
    var
    sectionTag = this.sectionTag,
    active = this.active,
    maxCards = this.maxCards,
    changeTasks = this.changeTasks;

    for(var i = 0; i < changeTasks; i++) {
      if(this.arrayPos > 0) {
        this.arrayPos--;
        $(sectionTag + " .task_card:nth-child("+ active[(this.arrayPos+maxCards)] +")" ).hide(0);
        $(sectionTag + " .task_card:nth-child("+ active[(this.arrayPos)] +")" ).fadeIn(250);
      }
    }
    this.changeSelectedNavList(this.arrayPos);
  };

