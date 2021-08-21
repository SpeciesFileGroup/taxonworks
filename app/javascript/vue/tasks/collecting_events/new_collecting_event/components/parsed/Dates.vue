<template>
  <div>
    <div>
      <label class="separate-bottom"><b>Start date</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="label-above">
          <label>Year</label>
          <input
            type="text"
            class="input-xsmall-width"
            maxlength="4"
            v-model="collectingEvent.start_date_year">
        </div>
        <div class="separate-left separate-right label-above">
          <label>Month</label>
          <input
            class="input-xsmall-width"
            type="text"
            maxlength="2"
            v-model="collectingEvent.start_date_month">
        </div>
        <div class="separate-right label-above">
          <label>Day</label>
          <input
            id="start-date-year"
            class="input-xsmall-width"
            type="text"
            maxlength="2"
            v-model="collectingEvent.start_date_day">
        </div>
        <div class="label-above">
          <label>&nbsp</label>
          <div class="horizontal-left-content">
            <button
              type="button"
              class="button normal-input button-default separate-right"
              @click="setActualDateForStart">
              Now
            </button>
          </div>
        </div>
      </div>
    </div>
    <div>
      <label class="separate-bottom"><b>End date</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="label-above">
          <label>Year</label>
          <input
            type="text"
            class="input-xsmall-width"
            maxlength="4"
            v-model="collectingEvent.end_date_year">
        </div>
        <div class="separate-left separate-right label-above">
          <label>Month</label>
          <input
            type="text"
            class="input-xsmall-width"
            maxlength="2"
            v-model="collectingEvent.end_date_month">
        </div>
        <div class="separate-right label-above">
          <label>Day</label>
          <input
            type="text"
            class="input-xsmall-width"
            maxlength="2"
            v-model="collectingEvent.end_date_day">
        </div>
        <div class="label-above">
          <label>&nbsp;</label>
          <button
            type="button"
            class="button normal-input button-default"
            @click="setActualDateForEnd">
            Now
          </button>
          <button
            type="button"
            class="button normal-input button-default"
            @click="cloneDate">
            Clone
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],
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
    cloneDate () {
      this.collectingEvent.end_date_day = this.collectingEvent.start_date_day
      this.collectingEvent.end_date_month = this.collectingEvent.start_date_month
      this.collectingEvent.end_date_year = this.collectingEvent.start_date_year
    }
  }
}
</script>
