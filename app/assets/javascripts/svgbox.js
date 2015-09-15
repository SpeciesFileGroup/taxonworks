window.onload = function() {
  var R = Raphael("canvas", 500, 500),
    c = R.rect(100, 100, 100, 100).attr({
      fill: "hsb(.8, 1, 1)",
      stroke: 1,
      opacity: .5,
      cursor: "move"
    }),
    s = R.rect(180, 180, 20, 20).attr({
      fill: "hsb(.8, .5, .5)",
      stroke: "none",
      opacity: .5
    }),
  // start, move, and up are the drag functions
    start = function () {
      // storing original coordinates
      this.ox = this.attr("x");
      this.oy = this.attr("y");
      this.attr({opacity: 1});

      this.sizer.ox = this.sizer.attr("x");
      this.sizer.oy = this.sizer.attr("y");
      this.sizer.attr({opacity: 1});
    },
    move = function (dx, dy) {
      // move will be called with dx and dy
      this.attr({x: this.ox + dx, y: this.oy + dy});
      this.sizer.attr({x: this.sizer.ox + dx, y: this.sizer.oy + dy});
    },
    up = function () {
      // restoring state
      this.attr({opacity: .5});
      this.sizer.attr({opacity: .5});
    },
    rstart = function () {
      // storing original coordinates
      this.ox = this.attr("x");
      this.oy = this.attr("y");

      this.box.ow = this.box.attr("width");
      this.box.oh = this.box.attr("height");
    },
    rmove = function (dx, dy) {
      // move will be called with dx and dy
      this.attr({x: this.ox + dx, y: this.oy + dy});
      this.box.attr({width: this.box.ow + dx, height: this.box.oh + dy});
    };
  // rstart and rmove are the resize functions;
  c.drag(move, start, up);
  c.sizer = s;
  s.drag(rmove, rstart);
  s.box = c;
};