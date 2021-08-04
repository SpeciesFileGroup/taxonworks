<template>
  <block-layout
    :warning="!collectingEvent.id">
    <template #header>
      <h3 v-hotkey="shortcuts">Collecting Event</h3>
    </template>
    <template #body>
      <fieldset class="separate-bottom">
        <legend>Selector</legend>
        <div class="horizontal-left-content align-start separate-bottom">
          <smart-selector
            class="full_width"
            ref="smartSelector"
            model="collecting_events"
            target="CollectionObject"
            klass="CollectionObject"
            pin-section="CollectingEvents"
            pin-type="CollectingEvent"
            v-model="collectingEvent"
            @selected="setCollectingEvent"/>
          <lock-component
            class="margin-small-left"
            v-model="locked.collecting_event"
          />
        </div>
        <div>
          <span data-icon="warning"/>
          <span
            v-if="collectingEvent.id">
            Modifying existing ({{ alreadyUsed }} uses)
          </span>
          <span v-else>
            New CE record.
          </span>
        </div>
        <div
          v-if="collectingEvent.id"
          class="flex-separate middle"
        >
          <p v-html="collectingEvent.object_tag" />
          <div class="horizontal-left-content">
            <div class="horizontal-left-content separate-right">
              <span v-if="collectingEvent.id">Sequential uses: {{ (this.subsequentialUses == 0 ? '-' : this.subsequentialUses) }}</span>
              <div
                v-if="collectingEvent.id"
                class="horizontal-left-content separate-left separate-right"
              >
                <radial-annotator :global-id="collectingEvent.global_id" />
                <radial-object :global-id="collectingEvent.global_id" />
                <pin-component
                  class="circle-button"
                  :object-id="collectingEvent.id"
                  type="CollectingEvent"
                />
                <button
                  type="button"
                  class="button circle-button button-default btn-undo"
                  @click="cleanCollectionEvent"
                />
              </div>
            </div>
            <button
              type="button"
              class="button normal-input button-default margin-small-left margin-small-right"
              @click="openBrowse"
            >
              Browse
            </button>
            <button
              type="button"
              class="button normal-input button-submit margin-small-right"
              @click="cloneCE"
            >
              Clone
            </button>
          </div>
        </div>
      </fieldset>
      <div class="horizontal-left-content align-start">
        <block-verbatin class="separate-right half_width" />
        <block-geography class="separate-left separate-right full_width" />
        <block-map class="separate-left full_width" />
      </div>
    </template>
  </block-layout>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { CollectingEvent, CollectionObject } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'
import BlockVerbatin from './components/verbatimLayout.vue'
import BlockGeography from './components/GeographyLayout.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import LockComponent from 'components/ui/VLock/index.vue'
import BlockMap from './components/map/main.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial.vue'
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import makeCollectingEvent from '../../const/collectingEvent.js'
import refreshSmartSelector from '../shared/refreshSmartSelector'
import platformKey from 'helpers/getMacKey'

export default {
  mixins: [refreshSmartSelector],
  components: {
    BlockLayout,
    BlockVerbatin,
    BlockGeography,
    SmartSelector,
    RadialAnnotator,
    RadialObject,
    PinComponent,
    BlockMap,
    LockComponent
  },
  computed: {
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+v`] = this.openNewCollectingEvent

      return keys
    },

    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionEvent, value)
      }
    },
    actualComponent () {
      return (this.view + 'Component')
    },
    subsequentialUses: {
      get () {
        return this.$store.getters[GetterNames.GetSubsequentialUses]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSubsequentialUses, value)
      }
    },
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit([MutationNames.SetLocked, value])
      }
    }
  },
  data () {
    return {
      alreadyUsed: 0
    }
  },
  watch: {
    async collectingEvent (newVal, oldVal) {
      if (!(newVal?.id &&
        oldVal?.id &&
        newVal.id === oldVal.id)) {
        this.subsequentialUses = 0
      }
      if (newVal.id) {
        this.alreadyUsed = (await CollectionObject.where({ collecting_event_ids: [newVal.id] })).body.length
      } else {
        this.alreadyUsed = 0
      }
    }
  },
  methods: {
    setCollectingEvent (ce) {
      this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), ce))
      this.$store.dispatch(ActionNames.GetLabels, ce.id)
    },
    cleanCollectionEvent () {
      this.$store.dispatch(ActionNames.NewCollectionEvent)
    },
    cloneCE () {
      CollectingEvent.clone(this.collectingEvent.id).then(response => {
        this.$store.commit(MutationNames.SetCollectionEvent, Object.assign(makeCollectingEvent(), response.body))
        this.$store.dispatch(ActionNames.SaveDigitalization)
      })
    },

    openBrowse () {
      window.open(`/tasks/collecting_events/browse?collecting_event_id=${this.collectingEvent.id}`)
    },

    openNewCollectingEvent () {
      window.open(this.collectingEvent.id
        ? `${RouteNames.NewCollectingEvent}?collecting_event_id=${this.collectingEvent.id}`
        : RouteNames.NewCollectingEvent
      )
    }
  }
}
</script>
