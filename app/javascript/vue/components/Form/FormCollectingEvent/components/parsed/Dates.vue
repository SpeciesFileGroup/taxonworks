<template>
  <div>
    <div>
      <label class="separate-bottom"><b>Start date</b></label>
      <div class="horizontal-left-content separate-bottom align-end gap-small">
        <date-fields
          v-model:year="collectingEvent.start_date_year"
          v-model:month="collectingEvent.start_date_month"
          v-model:day="collectingEvent.start_date_day"
          @change="
            () => {
              collectingEvent.isUnsaved = true
            }
          "
        />
        <date-now
          v-model:year="collectingEvent.start_date_year"
          v-model:month="collectingEvent.start_date_month"
          v-model:day="collectingEvent.start_date_day"
          @click="
            () => {
              collectingEvent.isUnsaved = true
            }
          "
        />
      </div>
    </div>
    <div>
      <label class="separate-bottom"><b>End date</b></label>
      <div class="horizontal-left-content separate-bottom align-end gap-small">
        <date-fields
          v-model:year="collectingEvent.end_date_year"
          v-model:month="collectingEvent.end_date_month"
          v-model:day="collectingEvent.end_date_day"
          @change="
            () => {
              collectingEvent.isUnsaved = true
            }
          "
        />
        <date-now
          v-model:year="collectingEvent.end_date_year"
          v-model:month="collectingEvent.end_date_month"
          v-model:day="collectingEvent.end_date_day"
          @click="
            () => {
              collectingEvent.isUnsaved = true
            }
          "
        />
        <VBtn
          v-if="!isStartDateEmpty && !isStartDateCloned"
          medium
          color="primary"
          variant="tonal"
          @click="cloneDate"
        >
          Clone
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import DateFields from '@/components/ui/Date/DateFields.vue'
import DateNow from '@/components/ui/Date/DateToday.vue'

const collectingEvent = defineModel()

const isStartDateEmpty = computed(() => {
  return (
    !collectingEvent.value?.start_date_year &&
    !collectingEvent.value?.start_date_month &&
    !collectingEvent.value?.start_date_day
  )
})

const isStartDateCloned = computed(() => {
  return (
    collectingEvent.value?.start_date_year ===
      collectingEvent.value?.end_date_year &&
    collectingEvent.value?.start_date_month ===
      collectingEvent.value?.end_date_month &&
    collectingEvent.value?.start_date_day ===
      collectingEvent.value?.end_date_day
  )
})

function cloneDate() {
  collectingEvent.value.end_date_day = collectingEvent.value.start_date_day
  collectingEvent.value.end_date_month = collectingEvent.value.start_date_month
  collectingEvent.value.end_date_year = collectingEvent.value.start_date_year
  collectingEvent.value.isUnsaved = true
}
</script>
