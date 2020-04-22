<template>
  <div>
    <spinner-component
      v-if="settings.isSaving"
      :full-screen="true"
      legend="Saving..."/>
    <h1>Buffered data</h1>
    <div class="horizontal-left-content align-start">
      <div class="separate-right">
        <div class="panel basic-information">
          <div
            class="header flex-separate middle">
            <h3>Collecting object</h3>
          </div>
        </div>
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
        <status-bar/>
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
          <div>
            <switch-component
              :options="collectingEventTabs"
              v-model="viewCe"/>
            <collecting-event
              class="separate-top"
              v-show="viewCe == 'Collecting event'"
              :collection-object="collectionObject"/>
            <existing-container
              v-show="viewCe == collectingEventTabs[1]"
              @search="setCount"/>
          </div>
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
import ExistingContainer from './components/existingContainer'
import StatusBar from './components/statusBar'

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
    ZoomComponent,
    ExistingContainer,
    StatusBar
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
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },
    collectingEvents () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    }
  },
  data () {
    return {
      image: undefined,
      canvasImage: undefined,
      nearbyCO: {},
      imagePosition: [],
      depictionTabs: ['Zoom', 'Group'],
      collectingEventTabs: ['Collecting event', 'Similar'],
      viewCe: 'Collecting event',
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
    },
    collectingEvents: {
      handler (newVal, oldVal) {
        if (this.settings.lastSave) {
          this.settings.lastChange = Date.now()
        } else {
          this.settings.lastSave = Date.now()
        }
      },
      deep: true
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
    },
    setCount (list) {
      this.$set(this.collectingEventTabs, 1, `Similar ${list.length ? `(${list.length})` : ''}`)
      if (this.viewCe !== this.collectingEventTabs[0]) {
        this.viewCe = this.collectingEventTabs[1]
      }
    }
  }
}
</script>