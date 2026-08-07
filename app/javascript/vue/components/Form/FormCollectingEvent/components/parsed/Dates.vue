<template>
  <div>
    <div>
      <label class="separate-bottom"><b>Start date</b></label>
      <div class="horizontal-left-content separate-bottom align-end">
        <date-fields
          v-model:year="collectingEvent.start_date_year"
          v-model:month="collectingEvent.start_date_month"
          v-model:day="collectingEvent.start_date_day"
          @change="() => { collectingEvent.isUnsaved = true }"
        />
        <date-now
          v-model:year="collectingEvent.start_date_year"
          v-model:month="collectingEvent.start_date_month"
          v-model:day="collectingEvent.start_date_day"
          @click="() => { collectingEvent.isUnsaved = true }"
        />
      </div>
    </div>
    <div>
      <label class="separate-bottom"><b>End date</b></label>
      <div class="horizontal-left-content separate-bottom align-end">
        <date-fields
          v-model:year="collectingEvent.end_date_year"
          v-model:month="collectingEvent.end_date_month"
          v-model:day="collectingEvent.end_date_day"
          @change="() => { collectingEvent.isUnsaved = true }"
        />
        <date-now
          v-model:year="collectingEvent.end_date_year"
          v-model:month="collectingEvent.end_date_month"
          v-model:day="collectingEvent.end_date_day"
          @click="() => { collectingEvent.isUnsaved = true }"
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
</template>

<script setup>
import DateFields from '@/components/ui/Date/DateFields.vue'
import DateNow from '@/components/ui/Date/DateToday.vue'

const collectingEvent = defineModel()

function cloneDate() {
  collectingEvent.value.end_date_day = collectingEvent.value.start_date_day
  collectingEvent.value.end_date_month = collectingEvent.value.start_date_month
  collectingEvent.value.end_date_year = collectingEvent.value.start_date_year
  collectingEvent.value.isUnsaved = true
}
</script>
