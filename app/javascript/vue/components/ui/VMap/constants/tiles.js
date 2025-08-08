export const MAP_TILES = {
  OSM: L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution:
      '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 18,
    className: 'map-tiles'
  }),
  Google: L.tileLayer(
    'http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z}',
    {
      attribution: 'Google',
      maxZoom: 18
    }
  ),
  GBIF: L.tileLayer(
    'https://tile.gbif.org/3857/omt/{z}/{x}/{y}@1x.png?style=gbif-natural-en',
    {
      attribution: 'GBIF',
      maxZoom: 18,
      className: 'map-tiles'
    }
  )
}
