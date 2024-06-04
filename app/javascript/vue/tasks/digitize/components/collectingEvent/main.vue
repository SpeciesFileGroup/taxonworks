<template>
  <block-layout :warning="!collectingEvent.id">
    <template #header>
      <h3>Collecting Event</h3>
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
            @selected="setCollectingEvent"
          />
          <lock-component
            class="margin-small-left"
            v-model="locked.collecting_event"
          />
        </div>
        <hr />
        <div>
          <span data-icon="warning" />
          <span v-if="collectingEvent.id">
            Modifying existing ({{ alreadyUsed }} uses)
          </span>
          <span v-else> New CE record. </span>
        </div>
        <div
          v-if="collectingEvent.id"
          class="flex-separate middle"
        >
          <p v-html="collectingEvent.object_tag" />
          <div class="horizontal-left-content">
            <div class="horizontal-left-content margin-small-right">
              <span v-if="collectingEvent.id"
                >Sequential uses:
                {{ subsequentialUses == 0 ? '-' : subsequentialUses }}</span
              >
              <div
                v-if="collectingEvent.id"
                class="horizontal-left-content margin-small-left gap-small"
              >
                <RadialAnnotator :global-id="collectingEvent.global_id" />
                <RadialObject :global-id="collectingEvent.global_id" />
                <VPin
                  class="circle-button"
                  :object-id="collectingEvent.id"
                  type="CollectingEvent"
                />
                <button
                  type="button"
                  class="button circle-button button-default btn-undo"
                  @click="cleanCollectingEvent"
                />
              </div>
            </div>
            <button
              type="button"
              class="button normal-input button-default margin-small-right"
              @click="openBrowse"
            >
              Browse
            </button>
            <button
              type="button"
              class="button normal-input button-submit"
              @click="cloneCE"
            >
              Clone
            </button>
          </div>
        </div>
      </fieldset>
      <div class="horizontal-left-content align-start">
        <BlockVerbatin class="separate-right half_width" />
        <BlockGeography class="separate-left separate-right full_width" />
        <BlockMap class="separate-left full_width" />
      </div>
    </template>
  </block-layout>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { RouteNames } from '@/routes/routes'
import BlockVerbatin from './components/verbatimLayout.vue'
import BlockGeography from './components/GeographyLayout.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import LockComponent from '@/components/ui/VLock/index.vue'
import BlockMap from './components/map/main.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import platformKey from '@/helpers/getPlatformKey'
import useHotkey from 'vue3-hotkey'
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'

const store = useStore()

const shortcuts = ref([
  {
    keys: [platformKey(), 'v'],
    handler() {
      openNewCollectingEvent()
    }
  }
])

useHotkey(shortcuts.value)

const collectingEvent = computed({
  get() {
    return store.getters[GetterNames.GetCollectingEvent]
  },
  set(value) {
    store.commit(MutationNames.SetCollectingEvent, value)
  }
})

const subsequentialUses = computed({
  get() {
    return store.getters[GetterNames.GetSubsequentialUses]
  },
  set(value) {
    store.commit(MutationNames.SetSubsequentialUses, value)
  }
})

const locked = computed({
  get() {
    return store.getters[GetterNames.GetLocked]
  },
  set(value) {
    store.commit([MutationNames.SetLocked, value])
  }
})

const alreadyUsed = computed(() => store.getters[GetterNames.GetCETotalUsed])

watch(collectingEvent, (newVal, oldVal) => {
  if (!(newVal?.id && oldVal?.id && newVal.id === oldVal.id)) {
    subsequentialUses.value = 0
  }
})

function setCollectingEvent(ce) {
  store.dispatch(ActionNames.GetCollectingEvent, ce.id)
  store.dispatch(ActionNames.GetLabels, ce.id)
  store.dispatch(ActionNames.LoadGeoreferences, ce.id)
}

function cleanCollectingEvent() {
  store.dispatch(ActionNames.NewCollectingEvent)
}

function cloneCE() {
  store.dispatch(ActionNames.CloneCollectingEvent, collectingEvent.value.id)
}

function openBrowse() {
  window.open(
    `/tasks/collecting_events/browse?collecting_event_id=${collectingEvent.value.id}`
  )
}

function openNewCollectingEvent() {
  window.open(
    collectingEvent.value.id
      ? `${RouteNames.NewCollectingEvent}?collecting_event_id=${collectingEvent.value.id}`
      : RouteNames.NewCollectingEvent
  )
}
</script>
