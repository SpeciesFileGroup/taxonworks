<template>
  <div>
    <label class="separate-bottom"><b>Start time</b></label>
    <DateTime
      v-model:hour="collectingEvent.time_start_hour"
      v-model:minutes="collectingEvent.time_start_minute"
      v-model:seconds="collectingEvent.time_start_second"
    />
    <label class="separate-bottom"><b>End time</b></label>
    <DateTime
      v-model:hour="collectingEvent.time_end_hour"
      v-model:minutes="collectingEvent.time_end_minute"
      v-model:seconds="collectingEvent.time_end_second"
    />
  </div>
</template>

<script>
import DateTime from '@/components/ui/Date/DateTime.vue'
import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],

  components: {
    DateTime
  }
}
</script>
