<template>
  <div>
    <spinner-component
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isSaving || isLoading"/>
    <div class="flex-separate middle">
      <h1>{{ collectingEvent.id ? 'Edit' : 'New' }} collecting event</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="settings.sortable">
            Sortable fields
          </label>
        </li>
        <li>
          <autocomplete
            url="/collecting_events/autocomplete"
            param="term"
            label="label_html"
            :clear-after="true"
            placeholder="Search a collecting event"
            @getItem="loadCollectingEvent($event.id)"/>
        </li>
      </ul>
    </div>
    <nav-bar>
      <div class="flex-separate full_width">
        <div class="middle margin-small-left">
          <span
            class="word_break"
            v-if="collectingEvent.id"
            v-html="collectingEvent.cached"/>
          <span v-else>New record</span>
          <template v-if="collectingEvent.id">
            <pin-component
              :object-id="collectingEvent.id"
              type="CollectingEvent"/>
            <radial-annotator :global-id="collectingEvent.global_id"/>
            <radial-object :global-id="collectingEvent.global_id"/>
          </template>
        </div>
        <ul class="context-menu no_bullets">
          <li class="horizontal-right-content">
            <span class="margin-small-right">Collection object:</span>
            <button
              type="button"
              class="button normal-input button-default margin-small-right"
              @click="openComprehensive"
              :disabled="!collectingEvent.id">
              New
            </button>
            <collection-objects-table
              class="margin-small-right"
              :ce-id="collectingEvent.id"/>
            <parse-data
              @onParse="setCollectingEvent"/>
          </li>
          <li class="horizontal-right-content">
            <button
              @click="showRecent = true"
              class="button normal-input button-default button-size margin-small-right"
              type="button">
              Recent
            </button>
            <navigate-component
              class="margin-small-right"
              :collectingEvent="collectingEvent"
              @select="loadCollectingEvent"
            />
            <button
              type="button"
              class="button normal-input button-submit margin-small-right"
              :disabled="!collectingEvent.id"
              @click="cloneCE"
            >
              Clone
            </button>
            <button
              v-shortkey="[getOSKey(), 's']"
              @shortkey="saveCollectingEvent"
              @click="saveCollectingEvent"
              class="button normal-input button-submit button-size margin-small-right"
              type="button">
              Save
            </button>
            <button
              v-shortkey="[getOSKey(), 'n']"
              @shortkey="reset"
              @click="reset"
              class="button normal-input button-default button-size"
              type="button">
              New
            </button>
          </li>
        </ul>
      </div>
    </nav-bar>
    <recent-component
      v-if="showRecent"
      @select="loadCollectingEvent($event.id)"
      @close="showRecent = false"/>
    <div class="horizontal-left-content align-start">
      <collecting-event-form
        v-model="collectingEvent"
        :sortable="settings.sortable"
        :soft-validation="validation"
        class="full_width" />
      <right-section
        :value="collectingEvent"
        :soft-validation="validation"
        @select="loadCollectingEvent($event.id)"
        class="separate-left" />
    </div>
  </div>
</template>

<script>

import { RouteNames } from 'routes/routes'
import Autocomplete from 'components/autocomplete'

import RecentComponent from './components/Recent'

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import GetOSKey from 'helpers/getMacKey'
import SetParam from 'helpers/setParam'

import PinComponent from 'components/pin'
import RightSection from './components/RightSection'
import NavBar from 'components/navBar'
import ParseData from './components/parseData'

import CollectingEventForm from './components/CollectingEventForm'
import makeCollectingEvent from './const/collectingEvent'
import CollectionObjectsTable from './components/CollectionObjectsTable.vue'
import NavigateComponent from './components/Navigate'
import SpinnerComponent from 'components/spinner'

import {
  CloneCollectionEvent,
  CreateCollectingEvent,
  CreateIdentifier,
  CreateLabel,
  GetCollectingEvent,
  GetCollectionObject,
  GetLabelsFromCE,
  GetSoftValidation,
  GetTripCodeByCE,
  UpdateCollectingEvent,
  UpdateIdentifier,
  UpdateLabel
} from './request/resources'

export default {
  components: {
    CollectionObjectsTable,
    RadialAnnotator,
    RadialObject,
    PinComponent,
    RightSection,
    NavBar,
    ParseData,
    RecentComponent,
    CollectingEventForm,
    Autocomplete,
    NavigateComponent,
    SpinnerComponent
  },
  computed: {
    collectingEvent: {
      get () {
        return this.ce
      },
      set (value) {
        this.ce = value
      }
    }
  },
  data () {
    return {
      isLoading: false,
      isSaving: false,
      settings: {
        sortable: false
      },
      showRecent: false,
      validation: [],
      ce: makeCollectingEvent()
    }
  },
  mounted () {
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+s`, 'Save', 'New collecting event')
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+n`, 'New', 'New collecting event')

    const urlParams = new URLSearchParams(window.location.search)
    const collectingEventId = urlParams.get('collecting_event_id')
    const collectionObjectId = urlParams.get('collection_object_id')

    if (/^\d+$/.test(collectingEventId)) {
      this.loadCollectingEvent(collectingEventId)
    } else if (/^\d+$/.test(collectionObjectId)) {
      GetCollectionObject(collectionObjectId).then(response => {
        const ceId = response.body.collecting_event_id
        if (ceId) {
          this.loadCollectingEvent(ceId)
        }
      })
    }
  },
  methods: {
    cloneCE () {
      CloneCollectionEvent(this.collectingEvent.id).then(response => {
        this.setCollectingEvent(response.body)
        TW.workbench.alert.create('Collecting event was successfully cloned.', 'notice')
      })
    },
    reset () {
      this.ce = makeCollectingEvent()
      this.validation = []
      SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id')
      SetParam(RouteNames.NewCollectingEvent, 'collection_object_id')
    },
    loadCollectingEvent (id) {
      this.isLoading = true
      GetCollectingEvent(id).then(async response => {
        const ce = response.body
        this.loadValidation(ce.global_id)
        const label = (await GetLabelsFromCE(ce.id)).body[0]
        const tripCode = (await GetTripCodeByCE(ce.id)).body[0]
        ce.label = label || makeCollectingEvent().label
        ce.tripCode = tripCode || makeCollectingEvent().tripCode
        ce.roles_attributes = ce.collector_roles || []
        this.setCollectingEvent(response.body)
      }).finally(() => {
        this.isLoading = false
      })
    },
    setCollectingEvent (ce) {
      this.collectingEvent = Object.assign({}, this.collectingEvent, ce)
      SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', this.collectingEvent.id)
    },
    async saveCollectingEvent () {
      const saveCE = this.collectingEvent.id ? UpdateCollectingEvent : CreateCollectingEvent
      const cloneCE = this.cleanCE()

      if (this.collectingEvent.units === 'ft') {
        ['minimum_elevation', 'maximum_elevation', 'elevation_precision'].forEach(key => {
          const elevationValue = Number(cloneCE[key])
          cloneCE[key] = elevationValue > 0 ? elevationValue / 3.281 : undefined
        })
        this.collectingEvent.units = undefined
      }

      this.isSaving = true
      saveCE(cloneCE).then(async response => {
        this.loadValidation(response.body.global_id)
        response.body.label = await this.saveLabel(this.collectingEvent)
        response.body.tripCode = await this.saveIdentifier(this.collectingEvent.tripCode)
        TW.workbench.alert.create(`Collecting event was successfully ${this.collectingEvent.id ? 'updated' : 'created'}.`, 'notice')
        this.setCollectingEvent(response.body)
      }).finally(() => {
        this.isSaving = false
      })
    },
    async saveLabel (ce) {
      const label = this.collectingEvent.label

      if (label.text.length && label.total) {
        label.label_object_id = ce.id
        return label.id ? (await UpdateLabel(label.id, { label: label })).body : (await CreateLabel({ label: label })).body
      } else {
        return label
      }
    },
    async saveIdentifier (identifier) {
      if (identifier.namespace_id && identifier.identifier) {
        identifier.identifier_object_id = this.collectingEvent.id
        return identifier.id ? (await UpdateIdentifier(identifier)).body : (await CreateIdentifier(identifier)).body
      } else {
        return identifier
      }
    },
    loadValidation (globalId) {
      GetSoftValidation(globalId).then(response => {
        this.validation = response.body.validations.soft_validations
      })
    },
    openComprehensive () {
      window.open(`${RouteNames.DigitizeTask}?collecting_event_id=${this.collectingEvent.id}`, '_self')
    },
    cleanCE () {
      const cloneCE = JSON.parse(JSON.stringify(this.collectingEvent))
      delete cloneCE.queueGeoreferences
      delete cloneCE.label
      delete cloneCE.geographicArea
      delete cloneCE.georeferences
      delete cloneCE.tripCode
      delete cloneCE.units
      return cloneCE
    },
    getOSKey: GetOSKey
  }
}
</script>
<style scoped>
  .button-size {
    width: 100px;
  }
</style>
