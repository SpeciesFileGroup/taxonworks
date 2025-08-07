export const zoomToFeature = (e) => {
  if (!props.zoomOnClick) return
  const layer = e.target
  if (props.fitBounds) {
    if (layer instanceof L.Marker || layer instanceof L.Circle) {
      mapObject.fitBounds([layer.getLatLng()], fitBoundsOptions.value)
    } else {
      mapObject.fitBounds(e.target.getBounds(), fitBoundsOptions.value)
    }
  }
}
