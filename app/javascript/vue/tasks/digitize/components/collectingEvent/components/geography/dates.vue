<template>
  <div>
    <div class="horizontal-left-content align-end margin-small-bottom">
      <date-fields
        v-model:year="collectingEvent.start_date_year"
        v-model:month="collectingEvent.start_date_month"
        v-model:day="collectingEvent.start_date_day"
      />
      <button
        type="button"
        class="button normal-input button-default margin-small-right"
        @click="setActualDateForStart">
        Now
      </button>
      <button
        type="button"
        class="button normal-input button-default"
        @click="cloneDate">
        Clone
      </button>
    </div>
    <div class="horizontal-left-content align-end">
      <date-fields
        v-model:year="collectingEvent.end_date_year"
        v-model:month="collectingEvent.end_date_month"
        v-model:day="collectingEvent.end_date_day"
      />
      <button
        type="button"
        class="button normal-input button-default"
        @click="setActualDateForEnd">
        Now
      </button>
    </div>
  </div>
</template>

<script>

import DateFields from 'components/ui/Date/DateFields.vue'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  components: { DateFields },

  methods: {
    setActualDateForStart () {
      const today = new Date()

      this.collectingEvent.start_date_day = today.getDate()
      this.collectingEvent.start_date_month = today.getMonth() + 1
      this.collectingEvent.start_date_year = today.getFullYear()
    },

    setActualDateForEnd () {
      const today = new Date()

      this.collectingEvent.end_date_day = today.getDate()
      this.collectingEvent.end_date_month = today.getMonth() + 1
      this.collectingEvent.end_date_year = today.getFullYear()
    },

    cloneDate() {
      this.collectingEvent.end_date_day = this.collectingEvent.start_date_day
      this.collectingEvent.end_date_month = this.collectingEvent.start_date_month
      this.collectingEvent.end_date_year = this.collectingEvent.start_date_year
    }
  }
}
</script>
