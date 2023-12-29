<template>
  <div>
    <VSpinner
      v-if="isUpdating"
      legend="Updating..."
    />
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <h3>
        {{ count }} {{ count === 1 ? 'record' : 'records' }} will be updated
      </h3>
      * Only fields that are checked will be updated.

      <div class="margin-xlarge-bottom margin-large-top">
        <label class="separate-bottom">
          <input
            type="checkbox"
            v-model="setStartDate"
          />
          <b>Start date</b>
        </label>
        <div
          class="horizontal-left-content margin-small-bottom align-end padding-large-left"
        >
          <DateFields
            v-model:year="startDate.start_date_year"
            v-model:month="startDate.start_date_month"
            v-model:day="startDate.start_date_day"
            @input="() => (setStartDate = true)"
          />
          <DateNow
            v-model:year="startDate.start_date_year"
            v-model:month="startDate.start_date_month"
            v-model:day="startDate.start_date_day"
            @click="() => (setStartDate = true)"
          />
        </div>
        <div>
          <label>
            <input
              type="checkbox"
              v-model="setEndDate"
            />
            <b>End date</b></label
          >
          <div
            class="horizontal-left-content separate-bottom align-end padding-large-left"
          >
            <DateFields
              v-model:year="endDate.end_date_year"
              v-model:month="endDate.end_date_month"
              v-model:day="endDate.end_date_day"
              @input="() => (setEndDate = true)"
            />
            <DateNow
              v-model:year="endDate.end_date_year"
              v-model:month="endDate.end_date_month"
              v-model:day="endDate.end_date_day"
              @click="() => (setEndDate = true)"
            />
            <button
              type="button"
              class="button normal-input button-default margin-small-left"
              @click="cloneDate"
            >
              Clone
            </button>
          </div>
        </div>
      </div>

      <div>
        <label class="separate-bottom">
          <input
            type="checkbox"
            v-model="setStartTime"
          />
          <b>Start time</b>
        </label>
        <DateTime
          class="padding-large-left"
          v-model:hour="startTime.time_start_hour"
          v-model:minutes="startTime.time_start_minute"
          v-model:seconds="startTime.time_start_second"
          @input="() => (setStartTime = true)"
        />
        <div>
          <label class="separate-bottom">
            <input
              type="checkbox"
              v-model="setEndTime"
            />
            <b>End time</b>
          </label>

          <DateTime
            class="padding-large-left"
            v-model:hour="endTime.time_end_hour"
            v-model:minutes="endTime.time_end_minute"
            v-model:seconds="endTime.time_end_second"
            @input="() => (setEndTime = true)"
          />
        </div>
      </div>

      <div
        class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
      >
        <UpdateBatch
          ref="updateBatchRef"
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="!anyFieldsSet || isCountExceeded"
          @update="updateMessage"
          @close="emit('close')"
        />

        <PreviewBatch
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="!anyFieldsSet || isCountExceeded"
          @finalize="
            () => {
              updateBatchRef.openModal()
            }
          "
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { CollectingEvent } from '@/routes/endpoints'
import { computed, reactive, ref } from 'vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import VSpinner from '@/components/spinner.vue'
import DateFields from '@/components/ui/Date/DateFields.vue'
import DateNow from '@/components/ui/Date/DateToday.vue'
import DateTime from '@/components/ui/Date/DateTime.vue'

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
const isUpdating = ref(false)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const updateBatchRef = ref(null)
const setStartDate = ref(false)
const setEndDate = ref(false)
const setStartTime = ref(false)
const setEndTime = ref(false)

const startDate = reactive({
  start_date_year: null,
  start_date_month: null,
  start_date_day: null
})
const endDate = reactive({
  end_date_year: null,
  end_date_month: null,
  end_date_day: null
})

const startTime = reactive({
  time_start_hour: null,
  time_start_minute: null,
  time_start_second: null
})

const endTime = reactive({
  time_end_hour: null,
  time_end_minute: null,
  time_end_second: null
})

const payload = computed(() => {
  const collectingEvent = {
    ...(setStartDate.value ? startDate : {}),
    ...(setEndDate.value ? endDate : {}),
    ...(setStartTime.value ? startTime : {}),
    ...(setEndTime.value ? endTime : {})
  }
  return {
    collecting_event_query: props.parameters,
    collecting_event: collectingEvent
  }
})

const anyFieldsSet = computed(() => {
  return (
    setStartDate.value ||
    setEndDate.value ||
    setStartTime.value ||
    setEndTime.value
  )
})

function cloneDate() {
  endDate.end_date_day = startDate.start_date_day
  endDate.end_date_month = startDate.start_date_month
  endDate.end_date_year = startDate.start_date_year
}

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collecting events queued for updating.`
    : `${data.updated.length} collecting events were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
