<template>
  <div>
    <spinner-component
      full-screen
      legend="Saving..."
      v-if="isSaving"/>
    <div class="flex-separate middle">
      <h1>New collecting event</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="settings.sortable">
            Sortable fields
          </label>
        </li>
      </ul>
    </div>
    <nav-bar>
      <div class="flex-separate full_width">
        <div class="horizontal-left-content">
          <autocomplete
            url="/collecting_events/autocomplete"
            param="term"
            label="label_html"
            :clear-after="true"
            placeholder="Search a collecting event"
            @getItem="loadCollectingEvent($event.id)"/>
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
        </div>
        <div class="horizontal-right-content">
          <collection-objects-table
            :ce-id="collectingEvent.id"/>
          <parse-data
            class="separate-left"
            @onParse="setCollectingEvent"/>
          <button
            type="button"
            class="button normal-input button-submit margin-small-left"
            :disabled="!collectingEvent.id"
            @click="cloneCE"
          >
            Clone
          </button>
          <button
            v-shortkey="[getOSKey(), 's']"
            @shortkey="saveCollectingEvent"
            @click="saveCollectingEvent"
            class="button normal-input button-submit button-size separate-left"
            type="button">
            Save
          </button>
          <button
            @click="showRecent = true"
            class="button normal-input button-default button-size separate-left"
            type="button">
            Recent
          </button>
          <button
            v-shortkey="[getOSKey(), 'n']"
            @shortkey="reset"
            @click="reset"
            class="button normal-input button-default button-size separate-left"
            type="button">
            New
          </button>
        </div>
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
import SpinnerComponent from 'components/spinner'

import {
  CloneCollectionEvent,
  CreateCollectingEvent,
  CreateLabel,
  GetCollectingEvent,
  GetLabelsFromCE,
  GetSoftValidation,
  UpdateCollectingEvent,
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

    if (/^\d+$/.test(collectingEventId)) {
      this.loadCollectingEvent(collectingEventId)
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
    },
    loadCollectingEvent (id) {
      GetCollectingEvent(id).then(async response => {
        this.loadValidation(response.body.global_id)
        const label = (await GetLabelsFromCE(response.body.id)).body[0]
        response.body.label = label || makeCollectingEvent().label
        this.setCollectingEvent(response.body)
      })
    },
    setCollectingEvent (ce) {
      this.collectingEvent = Object.assign({}, this.collectingEvent, ce)
      SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', this.collectingEvent.id)
    },
    async saveCollectingEvent () {
      const saveCE = this.collectingEvent.id ? UpdateCollectingEvent : CreateCollectingEvent

      this.isSaving = true
      saveCE(this.collectingEvent).then(async response => {
        this.loadValidation(response.body.global_id)
        response.body.label = await this.saveLabel(this.collectingEvent)
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
        return label.id ? (await UpdateLabel(label.id, label)).body : (await CreateLabel(label)).body
      } else {
        return label
      }
    },
    loadValidation (globalId) {
      GetSoftValidation(globalId).then(response => {
        this.validation = response.body.validations.soft_validations
      })
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
