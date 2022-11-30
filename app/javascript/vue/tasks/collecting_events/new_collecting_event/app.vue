<template>
  <div>
    <spinner-component
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isSaving || isLoading"
    />
    <div class="flex-separate middle">
      <h1>{{ collectingEvent.id ? 'Edit' : 'New' }} collecting event</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="settings.sortable"
            >
            Reorder fields
          </label>
        </li>
        <li>
          <autocomplete
            url="/collecting_events/autocomplete"
            param="term"
            label="label_html"
            :clear-after="true"
            placeholder="Search a collecting event"
            @get-item="loadCollectingEvent($event.id)"
          />
        </li>
      </ul>
    </div>
    <nav-bar v-hotkey="shortcuts">
      <div class="flex-separate full_width">
        <div class="middle margin-small-left">
          <span
            v-if="collectingEvent.id"
            class="margin-small-left"
            v-html="collectingEvent.object_tag"
          />
          <span
            class="margin-small-left"
            v-else
          >
            New record
          </span>
          <div
            v-if="collectingEvent.id"
            class="horizontal-left-content margin-small-left"
          >
            <pin-component
              class="circle-button"
              :object-id="collectingEvent.id"
              type="CollectingEvent"
            />
            <radial-annotator :global-id="collectingEvent.global_id" />
            <radial-object :global-id="collectingEvent.global_id" />
          </div>
        </div>
        <ul class="context-menu no_bullets">
          <li class="horizontal-right-content">
            <span
              v-if="isUnsaved"
              class="medium-icon margin-small-right"
              title="You have unsaved changes."
              data-icon="warning"
            />
            <button
              @click="showRecent = true"
              class="button normal-input button-default button-size margin-small-right"
              type="button"
            >
              Recent
            </button>
            <navigate-component
              class="margin-small-right"
              :collecting-event="collectingEvent"
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
              @click="saveCollectingEvent"
              class="button normal-input button-submit button-size margin-small-right"
              type="button"
            >
              Save
            </button>
            <button
              @click="reset"
              class="button normal-input button-default button-size"
              type="button"
            >
              New
            </button>
          </li>
        </ul>
      </div>
      <confirmation-modal ref="confirmationModal"/>
    </nav-bar>
    <recent-component
      v-if="showRecent"
      @select="loadCollectingEvent($event.id)"
      @close="showRecent = false"
    />
    <div class="horizontal-left-content align-start">
      <collecting-event-form
        v-model="collectingEvent"
        :sortable="settings.sortable"
        class="full_width"
      />
      <div class="margin-medium-left">
        <div class="panel content">
          <h3>Collection object</h3>
          <div class="horizontal-left-content">
            <button
              type="button"
              class="button normal-input button-default margin-small-right"
              @click="openComprehensive"
              :disabled="!collectingEvent.id"
            >
              New
            </button>
            <collection-objects-table
              class="margin-small-right"
              :ce-id="collectingEvent.id"
            />
            <parse-data
              @on-parse="setCollectingEvent"
            />
          </div>
        </div>
        <right-section
          v-model="collectingEvent"
          @select="loadCollectingEvent($event.id)"
        />
      </div>
    </div>
  </div>
</template>

<script>

import { RouteNames } from 'routes/routes'
import Autocomplete from 'components/ui/Autocomplete'

import RecentComponent from './components/Recent'

import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import platformKey from 'helpers/getPlatformKey'
import SetParam from 'helpers/setParam'

import PinComponent from 'components/ui/Pinboard/VPin.vue'
import RightSection from './components/RightSection'
import NavBar from 'components/layout/NavBar'
import ParseData from './components/parseData'

import CollectingEventForm from './components/CollectingEventForm'
import CollectionObjectsTable from './components/CollectionObjectsTable.vue'
import NavigateComponent from './components/Navigate'
import SpinnerComponent from 'components/spinner'
import ConfirmationModal from 'components/ConfirmationModal.vue'

import { ActionNames } from './store/actions/actions'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'

import { CollectionObject } from 'routes/endpoints'

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
    SpinnerComponent,
    ConfirmationModal
  },

  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+s`] = this.saveCollectingEvent
      keys[`${platformKey()}+n`] = this.reset

      return keys
    },

    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent, value)
      }
    },
    isUnsaved () {
      return this.$store.getters[GetterNames.IsUnsaved]
    },
    isLoading () {
      return this.$store.getters[GetterNames.GetSettings].isLoading
    },
    isSaving () {
      return this.$store.getters[GetterNames.GetSettings].isSaving
    }
  },

  data () {
    return {
      settings: {
        sortable: false
      },
      showRecent: false
    }
  },

  watch: {
    collectingEvent: {
      handler (_) {
        this.$store.commit(MutationNames.UpdateLastChange)
      },
      deep: true
    }
  },

  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const collectingEventId = urlParams.get('collecting_event_id')
    const collectionObjectId = urlParams.get('collection_object_id')

    TW.workbench.keyboard.createLegend(`${platformKey()}+s`, 'Save', 'New collecting event')
    TW.workbench.keyboard.createLegend(`${platformKey()}+n`, 'New', 'New collecting event')

    if (/^\d+$/.test(collectingEventId)) {
      this.loadCollectingEvent(collectingEventId)
    } else if (/^\d+$/.test(collectionObjectId)) {
      CollectionObject.find(collectionObjectId).then(response => {
        const ceId = response.body.collecting_event_id
        if (ceId) {
          this.loadCollectingEvent(ceId)
        }
      })
    }
  },

  methods: {
    async cloneCE () {
      const ok = await this.$refs.confirmationModal.show({
        title: 'Clone collecting event',
        message: 'This will clone the current collecting event. Are you sure you want to proceed?',
        confirmationWord: 'CLONE',
        okButton: 'Clone',
        cancelButton: 'Cancel',
        typeButton: 'submit'
      })

      if (ok) {
        this.$store.dispatch(ActionNames.CloneCollectingEvent)
      }
    },

    reset () {
      this.$store.dispatch(ActionNames.ResetStore)
      SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id')
      SetParam(RouteNames.NewCollectingEvent, 'collection_object_id')
    },
    loadCollectingEvent (id) {
      this.$store.dispatch(ActionNames.LoadCollectingEvent, id)
    },
    setCollectingEvent (ce) {
      this.collectingEvent = Object.assign({}, this.collectingEvent, ce)
      SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', this.collectingEvent.id)
    },
    saveCollectingEvent () {
      this.$store.dispatch(ActionNames.SaveCollectingEvent)
    },
    openComprehensive () {
      window.open(`${RouteNames.DigitizeTask}?collecting_event_id=${this.collectingEvent.id}`, '_self')
    }
  }
}
</script>
<style scoped>
  .button-size {
    width: 100px;
  }

</style>
