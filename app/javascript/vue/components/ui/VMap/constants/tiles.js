export const MAP_TILES = {
  OSM: {
    url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    options: {
      attribution:
        '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 18,
      className: 'map-tiles'
    }
  },

  Google: {
    url: 'http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z}',
    options: {
      attribution: 'Google',
      maxZoom: 18
    }
  },

  GBIF: {
    url: 'https://tile.gbif.org/3857/omt/{z}/{x}/{y}@1x.png?style=gbif-natural-en',
    options: {
      attribution: 'GBIF',
      maxZoom: 18,
      className: 'map-tiles'
    }
  }
}
