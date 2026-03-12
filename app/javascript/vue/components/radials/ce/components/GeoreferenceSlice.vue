<template>
  <div>
    <div class="margin-small-bottom">
      Re-use georeference efforts from past collecting events.
    </div>
    <fieldset>
      <legend>Collecting event</legend>
      <SmartSelector
        model="collecting_events"
        klass="CollectionObject"
        pin-section="CollectingEvents"
        pin-type="CollectingEvent"
        v-model="collectingEvent"
        @selected="setCollectingEvent"
      />
    </fieldset>
    <SmartSelectorItem
      :item="collectingEvent"
      @unset="reset"
    />
    <template v-if="collectingEvent">
      <VMap
        width="100%"
        height="300px"
        zoom="1"
        :zoom-bounds="5"
        :geojson="georeferences.map((item) => item.geo_json)"
      />
      <table class="table-striped full_width">
        <thead>
          <tr>
            <th class="w-2"></th>
            <th class="w-2">ID</th>
            <th>Type</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="georeference in georeferences"
            :key="georeference.id"
          >
            <td>
              <input
                type="checkbox"
                :value="georeference"
                v-model="selectedGeoreferences"
              />
            </td>
            <td v-text="georeference.id" />
            <td v-text="georeference.type" />
          </tr>
        </tbody>
      </table>
    </template>
    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectingEvent.batchUpdate"
        :payload="payload"
        :disabled="!selectedGeoreferences.length || isCountExceeded"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectingEvent.batchUpdate"
        :payload="payload"
        :disabled="!selectedGeoreferences.length || isCountExceeded"
        @finalize="
          () => {
            updateBatchRef.openModal()
          }
        "
      />
    </div>
  </div>
</template>

<script setup>
import { CollectingEvent, Georeference } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import VMap from '@/components/ui/VMap/VMap.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import updateMessage from '../utils/updateMessage.js'

const MAX_LIMIT = 250

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const collectingEvent = ref(null)
const georeferences = ref([])
const selectedGeoreferences = ref([])

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => ({
  collecting_event_query: props.parameters,
  collecting_event: {
    georeferences_attributes: selectedGeoreferences.value.map(
      ({
        geographic_item_id,
        type,
        error_radius,
        error_depth,
        error_geographic_item_id,
        is_public,
        api_request,
        year_georeferenced,
        month_georeferenced,
        day_georeferenced
      }) => ({
        geographic_item_id,
        type,
        error_radius,
        error_depth,
        error_geographic_item_id,
        is_public,
        api_request,
        year_georeferenced,
        month_georeferenced,
        day_georeferenced
      })
    )
  }
}))

function reset() {
  collectingEvent.value = null
  georeferences.value = []
  selectedGeoreferences.value = []
}

function setCollectingEvent(ce) {
  collectingEvent.value = ce
  Georeference.where({ collecting_event_id: [ce.id] }).then(({ body }) => {
    georeferences.value = body
    selectedGeoreferences.value = [...body]
  })
}
</script>
