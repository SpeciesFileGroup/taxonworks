function Sketcher( canvasID, brushImage ) {
  this.renderFunction = (brushImage == null || brushImage == undefined) ? this.updateCanvasByLine : this.updateCanvasByBrush;
  this.brush = brushImage;
  this.touchSupported = Modernizr.touch;
  this.canvasID = canvasID;
  this.canvas = $("#"+canvasID);
  this.context = this.canvas.get(0).getContext("2d");
  this.context.strokeStyle = "#000000";
  this.context.lineWidth = 3;
  this.lastMousePoint = {x:0, y:0};

  if (this.touchSupported) {
    this.mouseDownEvent = "touchstart";
    this.mouseMoveEvent = "touchmove";
    this.mouseUpEvent = "touchend";
  }
  else {
    this.mouseDownEvent = "mousedown";
    this.mouseMoveEvent = "mousemove";
    this.mouseUpEvent = "mouseup";
  }

  this.canvas.bind( this.mouseDownEvent, this.onCanvasMouseDown() );
}

Sketcher.prototype.onCanvasMouseDown = function () {
  var self = this;
  return function(event) {
    self.mouseMoveHandler = self.onCanvasMouseMove()
    self.mouseUpHandler = self.onCanvasMouseUp()

    $(document).bind( self.mouseMoveEvent, self.mouseMoveHandler );
    $(document).bind( self.mouseUpEvent, self.mouseUpHandler );

    self.updateMousePosition( event );
    self.renderFunction( event );
  }
}

Sketcher.prototype.onCanvasMouseMove = function () {
  var self = this;
  return function(event) {

    self.renderFunction( event );
    event.preventDefault();
    return false;
  }
};

var Trig = {
  distanceBetween2Points: function ( point1, point2 ) {

    var dx = point2.x - point1.x;
    var dy = point2.y - point1.y;
    return Math.sqrt( Math.pow( dx, 2 ) + Math.pow( dy, 2 ) );
  },

  angleBetween2Points: function ( point1, point2 ) {

    var dx = point2.x - point1.x;
    var dy = point2.y - point1.y;
    return Math.atan2( dx, dy );
  }
}

Sketcher.prototype.onCanvasMouseUp = function (event) {
  var self = this;
  return function(event) {

    $(document).unbind( self.mouseMoveEvent, self.mouseMoveHandler );
    $(document).unbind( self.mouseUpEvent, self.mouseUpHandler );

    self.mouseMoveHandler = null;
    self.mouseUpHandler = null;
  }
}

Sketcher.prototype.updateMousePosition = function (event) {
  var target;
  if (this.touchSupported) {
    target = event.originalEvent.touches[0]
  }
  else {
    target = event;
  }

  var offset = this.canvas.offset();
  this.lastMousePoint.x = target.pageX - offset.left;
  this.lastMousePoint.y = target.pageY - offset.top;

}

Sketcher.prototype.updateCanvasByLine = function (event) {
  if(cursorMode == "DRAW") {
    this.context.beginPath();
    this.context.moveTo(this.lastMousePoint.x, this.lastMousePoint.y);
    this.updateMousePosition(event);
    this.context.lineTo(this.lastMousePoint.x, this.lastMousePoint.y);
    this.context.stroke();
  }
  else {
    var oldX = this.lastMousePoint.x;
    var oldY = this.lastMousePoint.y;
    this.context.moveTo(this.lastMousePoint.x, this.lastMousePoint.y);
    this.updateMousePosition(event);
    this.context.moveTo(this.lastMousePoint.x, this.lastMousePoint.y);
    xS = xS + oldX - this.lastMousePoint.x;
    yS = yS + oldY - this.lastMousePoint.y;
    renderImage();
  }
}

Sketcher.prototype.updateCanvasByBrush = function (event) {
  var halfBrushW = this.brush.width/2;
  var halfBrushH = this.brush.height/2;

  var start = { x:this.lastMousePoint.x, y: this.lastMousePoint.y };
  this.updateMousePosition( event );
  var end = { x:this.lastMousePoint.x, y: this.lastMousePoint.y };

  var distance = parseInt( Trig.distanceBetween2Points( start, end ) );
  var angle = Trig.angleBetween2Points( start, end );

  var x,y;

  for ( var z=0; (z<=distance || z==0); z++ )
  {
    x = start.x + (Math.sin(angle) * z) - halfBrushW;
    y = start.y + (Math.cos(angle) * z) - halfBrushH;
    //console.log( x, y, angle, z );
    this.context.drawImage(this.brush, x, y);
  }
}

Sketcher.prototype.toString = function () {

  var dataString = this.canvas.get(0).toDataURL("image/png");
  var index = dataString.indexOf( "," )+1;
  dataString = dataString.substring( index );

  return dataString;
}

Sketcher.prototype.toDataURL = function () {

  var dataString = this.canvas.get(0).toDataURL("image/png");
  return dataString;
}

Sketcher.prototype.clear = function () {

  var c = this.canvas[0];
  this.context.clearRect( 0, 0, c.width, c.height );
}