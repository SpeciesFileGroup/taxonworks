<template>
  <div>
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
        <div class="middle">
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
        <div class="horizontal-right-content">
          <button
            v-shortkey="[getOSKey(), 's']"
            @shortkey="saveCollectingEvent"
            @click="saveCollectingEvent"
            class="button normal-input button-submit button-size separate-right separate-left"
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
      @select="setCollectingEvent"
      @close="showRecent = false"/>
    <div class="horizontal-left-content align-start">
      <collecting-event-form class="full_width"/>
      <right-section class="separate-left"/>
    </div>
  </div>
</template>

<script>

import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { RouteNames } from 'routes/routes'

import RecentComponent from './components/Recent'

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import GetOSKey from 'helpers/getMacKey'
import SetParam from 'helpers/setParam'

import PinComponent from 'components/pin'
import RightSection from './components/RightSection'
import NavBar from 'components/navBar'

import collectingEventForm from './components/CollectingEventForm'

import {
  GetCollectingEvent,
  GetUserPreferences,
  CreateCollectingEvent,
  UpdateCollectingEvent
} from './request/resources'

export default {
  components: {
    RadialAnnotator,
    RadialObject,
    PinComponent,
    RightSection,
    NavBar,
    RecentComponent,
    collectingEventForm
  },
  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    }
  },
  data () {
    return {
      settings: {},
      showRecent: false
    }
  },
  mounted () {
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+s`, 'Save', 'New collecting event')
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+n`, 'New', 'New collecting event')

    const urlParams = new URLSearchParams(window.location.search)
    const collectingEventId = urlParams.get('collecting_event_id')

    if (/^\d+$/.test(collectingEventId)) {
      // this.$store.dispatch(ActionNames.LoadCollectingEvent, collectingEventId)
    }

    GetUserPreferences().then(response => {
      // this.$store.commit(MutationNames.SetPreferences, response.body)
    })
  },
  methods: {
    reset () {
      // this.$store.dispatch(ActionNames.ResetApp)
    },
    loadCollectingEvent (id) {
      GetCollectingEvent(id).then(response => {
        this.setCollectingEvent(response.body)
        SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', id)
      })
    },
    setCollectingEvent (ce) {
      this.collectingEvent = ce
    },
    saveCollectingEvent () {
      if (this.collectingEvent.id) {
        UpdateCollectingEvent(this.collectingEvent).then(response => {
          this.collectingEvent = response.body
        })
      } else {
        CreateCollectingEvent(this.collectingEvent).then(response => {
          this.collectingEvent = response.body
        })
      }
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
