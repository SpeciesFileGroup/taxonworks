export function setRectangleSelectTool({ map, layerGroup, callback }) {
  let startPoint = null
  let selectionRect = null
  let isSelecting = false

  map.pm.Toolbar.createCustomControl({
    name: 'selection',
    block: 'custom',
    title: 'Selection',
    className: 'leaflet-pm-icon-selection',
    onClick: function () {
      if (this.toggleStatus) {
        disableBoxSelect()
      } else {
        enableBoxSelect()
      }
    }
  })

  function enableBoxSelect() {
    map.on('mousedown', onMouseDown)
    map.on('mousemove', onMouseMove)
    map.on('mouseup', onMouseUp)
    map.on('mouseout', onMouseUp)

    map.getContainer().style.cursor = 'crosshair'
    map.dragging.disable()
    map.boxZoom.disable()
  }

  function disableBoxSelect() {
    map.off('mousedown', onMouseDown)
    map.off('mousemove', onMouseMove)
    map.off('mouseup', onMouseUp)
    map.off('mouseout', onMouseUp)

    map.getContainer().style.cursor = ''
    map.dragging.enable()
    map.boxZoom.enable()
  }

  function onMouseDown(e) {
    e.originalEvent.preventDefault()
    e.originalEvent.stopPropagation()

    isSelecting = true
    startPoint = e.latlng
    selectionRect = L.rectangle(L.latLngBounds(startPoint, startPoint), {
      color: 'blue',
      weight: 1,
      dashArray: '4',
      fillOpacity: 0.1,
      interactive: false
    }).addTo(map)
  }

  function onMouseMove(e) {
    if (!isSelecting || !selectionRect) return

    const bounds = L.latLngBounds(startPoint, e.latlng)
    selectionRect.setBounds(bounds)
  }

  function onMouseUp(e) {
    if (!isSelecting || !selectionRect) return

    const bounds = selectionRect.getBounds()
    map.removeLayer(selectionRect)
    selectionRect = null
    isSelecting = false

    const selected = []

    layerGroup.eachLayer((layer) => {
      if (!layer || layer === selectionRect) return

      if (layer.getLatLng && bounds.contains(layer.getLatLng())) {
        selected.push(layer)
      } else if (layer.getBounds && bounds.contains(layer.getBounds())) {
        selected.push(layer)
      }
    })

    callback(selected)
  }
}
