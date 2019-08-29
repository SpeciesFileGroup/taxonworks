<template>
  <div>
    <spinner-component
      v-if="settings.isSaving"
      :full-screen="true"
      legend="Saving..."/>
    <h1>Buffered data</h1>
    <div class="horizontal-left-content align-start">
      <div class="separate-right">
        <h3>Collection object</h3>
        <div class="panel content">
          <nav-collection-objects
            :co-objects="nearbyCO"/>
          <hr>
          <collection-object-container/>
          <switch-component
            class="separate-bottom separate-top"
            :options="depictionTabs"
            v-model="view"/>
          <div>
            <zoom-component/>
          </div>
        </div>
      </div>

      <div class="separate-left">
        <h3>Collecting event</h3>
        <div class="panel content">
          <div class="separate-bottom">
            <button
              type="button"
              class="button normal-input button-default"
              :disabled="!collectionObject.id"
              @click="openDigitize()">
              Open full
            </button>
            <button
              type="button"
              class="button normal-input button-default"
              @click="saveSqed">
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
  </div>
</template>

<script>

import CollectingEvent from './components/collectingEvent'
import ZoomComponent from './components/zoom'
import NavCollectionObjects from './components/navCollectionObjects'
import CollectionObjectContainer from './components/collectionObject'
import SwitchComponent from 'components/switch'
import SpinnerComponent from 'components/spinner'

import { GetCollectionObject, GetNearbyCOFromDepictionSqedId } from './request/resource'
import { RouteNames } from 'routes/routes'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

export default {
  components: {
    CollectingEvent,
    NavCollectionObjects,
    CollectionObjectContainer,
    SwitchComponent,
    SpinnerComponent,
    ZoomComponent
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
    },
    settings () {
      return this.$store.getters[GetterNames.GetSettings]
    }
  },
  data () {
    return {
      image: undefined,
      canvasImage: undefined,
      nearbyCO: {},
      imagePosition: [],
      depictionTabs: ['Zoom', 'Group'],
      view: 'Zoom'
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
    },
    saveSqed () {
      this.$store.dispatch(ActionNames.SaveSqed)
    }
  }
}
</script>