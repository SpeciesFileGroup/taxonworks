<template>
  <div>
    <b>Start date</b>
    <div class="horizontal-left-content align-end margin-small-bottom">
      <date-fields
        v-model:year="collectingEvent.start_date_year"
        v-model:month="collectingEvent.start_date_month"
        v-model:day="collectingEvent.start_date_day"
      />
      <date-now
        v-model:year="collectingEvent.start_date_year"
        v-model:month="collectingEvent.start_date_month"
        v-model:day="collectingEvent.start_date_day"
      />
      <button
        type="button"
        class="button normal-input button-default margin-small-left"
        @click="cloneDate">
        Clone
      </button>
    </div>
    <b>End date</b>
    <div class="horizontal-left-content align-end">
      <date-fields
        v-model:year="collectingEvent.end_date_year"
        v-model:month="collectingEvent.end_date_month"
        v-model:day="collectingEvent.end_date_day"
      />
      <date-now
        v-model:year="collectingEvent.end_date_year"
        v-model:month="collectingEvent.end_date_month"
        v-model:day="collectingEvent.end_date_day"
      />
    </div>
  </div>
</template>

<script>

import DateFields from 'components/ui/Date/DateFields.vue'
import DateNow from 'components/ui/Date/DateToday.vue'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  components: {
    DateFields,
    DateNow
  },

  methods: {
    cloneDate() {
      this.collectingEvent.end_date_day = this.collectingEvent.start_date_day
      this.collectingEvent.end_date_month = this.collectingEvent.start_date_month
      this.collectingEvent.end_date_year = this.collectingEvent.start_date_year
    }
  }
}
</script>
