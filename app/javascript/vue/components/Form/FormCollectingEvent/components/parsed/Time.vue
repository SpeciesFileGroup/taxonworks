<template>
  <div>
    <label><b>Start time</b></label>
    <DateTime
      class="margin-small-bottom"
      v-model:hour="collectingEvent.time_start_hour"
      v-model:minutes="collectingEvent.time_start_minute"
      v-model:seconds="collectingEvent.time_start_second"
      @change="
        () => {
          collectingEvent.isUnsaved = true
        }
      "
    />
    <label><b>End time</b></label>
    <DateTime
      v-model:hour="collectingEvent.time_end_hour"
      v-model:minutes="collectingEvent.time_end_minute"
      v-model:seconds="collectingEvent.time_end_second"
      @change="
        () => {
          collectingEvent.isUnsaved = true
        }
      "
    />
  </div>
</template>

<script setup>
import DateTime from '@/components/ui/Date/DateTime.vue'

const collectingEvent = defineModel()
</script>
