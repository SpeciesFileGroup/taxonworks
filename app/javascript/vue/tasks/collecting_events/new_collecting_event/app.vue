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
            v-shortkey="[getMacKey(), 's']"
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
            v-shortkey="[getMacKey(), 'n']"
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
      @close="showRecent = false"/>
    <div class="horizontal-left-content align-start">
      <collecting-event-form class="full_width"/>
      <right-section class="separate-left"/>
    </div>
  </div>
</template>

<script>

import RecentComponent from './components/Recent'

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import GetMacKey from 'helpers/getMacKey'

import PinComponent from 'components/pin'

import { GetUserPreferences } from './request/resources'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'

import RightSection from './components/RightSection'
import NavBar from 'components/navBar'

import collectingEventForm from './components/CollectingEventForm'


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
    TW.workbench.keyboard.createLegend(`${this.getMacKey()}+s`, 'Save', 'New collecting event')
    TW.workbench.keyboard.createLegend(`${this.getMacKey()}+n`, 'New', 'New collecting event')

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
    saveCollectingEvent () {
      // this.$store.dispatch(ActionNames.SaveCollectingEvent)
    },
    getMacKey: GetMacKey
  }
}
</script>
<style scoped>
  .button-size {
    width: 100px;
  }
</style>
