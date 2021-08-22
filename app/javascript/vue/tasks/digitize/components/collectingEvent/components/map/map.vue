<template>
  <div>
    <div v-show="latitude && longitude">
      <div style="height: 10%; overflow: auto;">
        Map verification
      </div>
      <div
        :style="{ width: width, height: height }"
        ref="leafletMap"
        id="preview-map"
      />
    </div>

    <div
      v-if="(!latitude || !longitude) && (collectingEvent.verbatim_latitude || collectingEvent.verbatim_longitude)"
      class="panel aligner middle"
      style="height: 300px; align-items: center; width:100%; text-align: center;">
      <h3>
        <span class="soft_validation">
          <span data-icon="warning"/>
          <span>Verbatim latitude/longitude unparsable or incomplete, location preview unavailable.</span>
        </span>
      </h3>
    </div>

    <div
      v-show="!collectingEvent.verbatim_latitude && !collectingEvent.verbatim_longitude"
      class="panel aligner"
      style="height: 300px; align-items: center; width:100%; text-align: center;">
      <h3>Provide verbatim latitude/longitude to preview location on map.</h3>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters.js'
import L from 'leaflet'
import convertDMS from '../../../../helpers/parseDMS.js'
import iconRetina from 'leaflet/dist/images/marker-icon-2x.png'
import iconUrl from 'leaflet/dist/images/marker-icon.png'
import shadowUrl from 'leaflet/dist/images/marker-shadow.png'

delete L.Icon.Default.prototype._getIconUrl

L.Icon.Default.mergeOptions({
  iconRetinaUrl: iconRetina,
  iconUrl: iconUrl,
  shadowUrl: shadowUrl
})

export default {
  computed: {
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    },
    latitude () {
      return convertDMS(this.$store.getters[GetterNames.GetCollectingEvent].verbatim_latitude)
    },
    longitude () {
      return convertDMS(this.$store.getters[GetterNames.GetCollectingEvent].verbatim_longitude)
    }
  },
  data () {
    return {
      zoom:8,
      center: L.latLng(0, 0),
      url:'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      attribution:'&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
      marker: L.latLng(0, 0),
      width: '100%',
      height: '300px',
      mapObject: undefined
    } 
  },
  watch: {
    latitude (newVal) {
      if (newVal && this.longitude) {
        this.setCoordinates(L.latLng(newVal, this.longitude))
        this.$nextTick(() => {
          this.mapObject.invalidateSize()
        })
      }
    },
    longitude (newVal) {
      if (newVal && this.latitude) {
        this.setCoordinates(L.latLng(this.latitude, newVal))
        this.$nextTick(() => {
          this.mapObject.invalidateSize()
        })
      }
    }
  },
  mounted () {
    this.mapObject = L.map('preview-map', {
      center: this.center,
      zoom: this.zoom
    })
    L.tileLayer(this.url, {
      attribution: this.attribution,
      maxZoom: this.zoom
    }).addTo(this.mapObject)
    this.initEvents()
  },
  methods: {
    setCoordinates (coordinates) {
      this.center = coordinates
      if (this.marker)
        this.mapObject.removeLayer(this.marker)
      this.marker = L.marker(coordinates).addTo(this.mapObject)
      this.mapObject.invalidateSize()
      this.mapObject.panTo(this.center)
    },
    convertDMS (value) {
      try {
        return parseDMS(value)
      }
      catch (error) {
        return undefined
      }
    },
    resizeMap (mutationsList, observer) {
      if (this.$el.clientWidth !== this.mapSize) {
        this.$nextTick(() => {
          this.mapObject.invalidateSize()
        })
      }
    },
    initEvents () {
      this.mapSize = this.$el.clientWidth
      this.observeMap = new MutationObserver(this.resizeMap)
      this.observeMap.observe(this.$el, { attributes: true, childList: true, subtree: true })
    },
  }
}
</script>
<style scoped>
.aligner {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
