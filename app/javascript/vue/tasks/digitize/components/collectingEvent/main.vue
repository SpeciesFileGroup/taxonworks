<template>
  <BlockLayout :warning="!collectingEvent.id">
    <template #header>
      <h3>Collecting Event</h3>
    </template>
    <template #body>
      <fieldset class="separate-bottom">
        <legend>Selector</legend>
        <div class="horizontal-left-content align-start separate-bottom">
          <SmartSelector
            ref="smartSelector"
            class="full_width"
            v-model="collectingEvent"
            model="collecting_events"
            pin-section="CollectingEvents"
            :pin-type="COLLECTING_EVENT"
            :target="COLLECTION_OBJECT"
            :klass="COLLECTION_OBJECT"
            @selected="(item) => collectingEventStore.load(item.id)"
          />
          <VLock
            class="margin-small-left"
            v-model="locked.collecting_event"
          />
        </div>
        <hr class="divisor" />
        <div
          class="horizontal-left-content gap-small middle margin-medium-top margin-small-bottom"
        >
          <VIcon
            name="attention"
            color="attention"
            small
          />
          <span v-if="collectingEvent.id">
            Modifying existing ({{ collectingEventStore.totalUsed }} uses)
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
                  @click="() => collectingEventStore.reset()"
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
            <CloneForm @clone="(ce) => collectingEventStore.load(ce.id)" />
          </div>
        </div>
      </fieldset>
      <div class="horizontal-left-content align-start">
        <FormCollectingEvent
          class="full_width"
          :sortable="settings.sortable"
          :buffered-collecting-event="
            collectionObject.buffered_collecting_event
          "
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { useHotkey } from '@/composables'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { RouteNames } from '@/routes/routes'
import { COLLECTING_EVENT, COLLECTION_OBJECT } from '@/constants/modelTypes.js'
import FormCollectingEvent from '@/components/Form/FormCollectingEvent/FormCollectingEvent.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VLock from '@/components/ui/VLock/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import platformKey from '@/helpers/getPlatformKey'
import useCollectingEventStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'
import CloneForm from '@/tasks/collecting_events/new_collecting_event/components/CloneForm.vue'

const store = useStore()
const collectingEventStore = useCollectingEventStore()

const shortcuts = ref([
  {
    keys: [platformKey(), 'v'],
    handler() {
      openNewCollectingEvent()
    }
  }
])

useHotkey(shortcuts.value)

const collectingEvent = computed(() => collectingEventStore.collectingEvent)
const collectionObject = computed(
  () => store.getters[GetterNames.GetCollectionObject]
)

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

const settings = computed(() => store.getters[GetterNames.GetSettings])

watch(
  () => collectingEvent.value.id,
  async (newVal, oldVal) => {
    if (!(newVal && oldVal && newVal === oldVal)) {
      subsequentialUses.value = 0
    }
  }
)

function openBrowse() {
  window.open(
    `/tasks/collecting_events/browse?collecting_event_id=${collectingEvent.value.id}`
  )
}

function openNewCollectingEvent() {
  window.open(
    collectingEvent.value.id
      ? `${RouteNames.NewCollectingEvent}?collecting_event_id=${collectingEvent.value.id}`
      : RouteNames.NewCollectingEvent,
    '_self'
  )
}
</script>
