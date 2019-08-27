<template>
  <div>
    <h1>Buffered data</h1>
    <div class="horizontal-left-content align-start">
      <div>
        <h2>Collection object</h2>
        <nav-collection-objects
          :co-objects="nearbyCO"/>
        <hr>
        <collection-object-container/>
        <div class="flexbox">
          <depictions-container
            :depictions="depictions"
            @selectedImage="image=$event"/>
          <div>
            <switch-component
              :options="depictionTabs"
              v-model="view"/>
            <image-editor
              :image="image"
              @imagePosition="setImageValues"/>
            <canvas-container :image="canvasImage"/>
          </div>
        </div>
      </div>

      <div>
        <h2>Collecting event</h2>
        <div>
          <button
            type="button"
            class="button normal-input button-default"
            :disabled="!collectionObject.id"
            @click="openDigitize()">
            Open full
          </button>
          <button
            type="button"
            class="button normal-input button-default">
            Save
          </button>
          <button
            type="button"
            class="button normal-input button-submit"> <!-- Next Sqed -->
            Save and next
          </button>
        </div>
        <collecting-event
          :collection-object="collectionObject"/>
      </div>
    </div>
  </div>
</template>

<script>

import CollectingEvent from './components/collectingEvent'
import DepictionsContainer from './components/depictionsContainer'
import ImageEditor from './components/imageEditor'
import CanvasContainer from './components/canvasContainer'
import NavCollectionObjects from './components/navCollectionObjects'
import CollectionObjectContainer from './components/collectionObject'
import SwitchComponent from 'components/switch'

import { GetCollectionObject, GetNearbyCOFromDepictionSqedId } from './request/resource'
import { RouteNames } from 'routes/routes'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    CanvasContainer,
    CollectingEvent,
    DepictionsContainer,
    ImageEditor,
    NavCollectionObjects,
    CollectionObjectContainer,
    SwitchComponent
  },
  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    },
    depictions () {
      return this.$store.getters[GetterNames.GetSqedDepictions]
    }
  },
  data () {
    return {
      image: undefined,
      canvasImage: undefined,
      nearbyCO: {},
      imagePosition: [],
      depictionTabs: ['Zoom', 'Group'],
      view: undefined
    }
  },
  mounted () {
    this.checkForParams()
  },
  watch: {
    depictions (newVal) {
      if (newVal && newVal.length) {
        GetNearbyCOFromDepictionSqedId(newVal[0].sqed_depiction.id).then(response => {
          this.nearbyCO = response.body
        })
      }
    }
  },
  methods: {
    checkForParams () {
      const urlParams = new URLSearchParams(window.location.search)
      const COId = urlParams.get('collection_object_id')

      if (/^\d+$/.test(COId)) {
        this.$store.dispatch(ActionNames.LoadSqued, COId)
        this.$store.dispatch(ActionNames.LoadSqedDepictions, COId)
        GetCollectionObject(COId).then(response => {
          this.collectionObject = response.body
        })
      }
    },
    setImageValues (values) {
      this.canvasImage = {
        src: this.image.large_image,
        x: values.x,
        y: values.y,
        width: values.width,
        height: values.height
      }
    },
    openDigitize (id) {
      window.open(`${RouteNames.DigitizeTask}?collection_object_id=${this.collectionObject.id}`, '_self')
    }
  }
}
</script>