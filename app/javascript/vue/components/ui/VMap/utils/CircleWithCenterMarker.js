import L from 'leaflet'

const MIN_VISIBLE_RADIUS_IN_PIXELS = 4

const FORWARDED_MARKER_EVENTS = [
  'click',
  'dblclick',
  'mousedown',
  'mouseup',
  'mouseover',
  'mouseout',
  'contextmenu'
]

export const CircleWithCenterMarker = L.Circle.extend({
  options: {
    minVisibleRadiusInPixels: MIN_VISIBLE_RADIUS_IN_PIXELS,
    centerMarkerIcon: undefined
  },

  onRemove(map) {
    // Also covers the cluster group swapping this circle out for a cluster icon
    // and `drawnItems.clearLayers()` on a geojson change.
    this._removeCenterMarker()

    return L.Circle.prototype.onRemove.call(this, map)
  },

  _project() {
    L.Circle.prototype._project.call(this)

    // Leaflet reprojects every path on zoom, so this is the cheapest place to
    // notice that the rendered radius crossed the threshold -- no zoom listener.
    this._syncCenterMarker()
  },

  _syncCenterMarker() {
    if (!this._map || !this.options.centerMarkerIcon) return

    if (this._radius < this.options.minVisibleRadiusInPixels) {
      this._addCenterMarker()

      // The circle moves under us: the cluster group parks children at the
      // cluster position for the zoom-in animation before restoring them, and
      // spiderfy walks them out along their legs. Both go through `setLatLng`,
      // which reprojects, so following the circle here is enough.
      this._centerMarker.setLatLng(this.getLatLng())
    } else {
      this._removeCenterMarker()
    }
  },

  _addCenterMarker() {
    if (this._centerMarker) return

    // Only one of the two is ever drawn. `L.Circle` overrides `setStyle` back to
    // `Path.prototype.setStyle`, so unlike on a `CircleMarker` this cannot reach
    // `setRadius` and corrupt the metric radius.
    this._styleBeforeCenterMarker = {
      stroke: this.options.stroke,
      fill: this.options.fill
    }
    this.setStyle({ stroke: false, fill: false })

    const centerMarker = L.marker(this.getLatLng(), {
      icon: this.options.centerMarkerIcon,
      keyboard: false,
      pmIgnore: true
    })

    FORWARDED_MARKER_EVENTS.forEach((eventName) => {
      centerMarker.on(eventName, (event) => this.fire(eventName, event))
    })

    centerMarker.addTo(this._map)

    this._centerMarker = centerMarker
  },

  _removeCenterMarker() {
    if (!this._centerMarker) return

    this._centerMarker.remove()
    this._centerMarker = null

    if (this._styleBeforeCenterMarker) {
      this.setStyle(this._styleBeforeCenterMarker)
      this._styleBeforeCenterMarker = null
    }
  }
})
