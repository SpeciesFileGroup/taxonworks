<template>
  <div>
    <div>
      <label class="separate-bottom"><b>Start date</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="label-above">
          <label>Day</label>
          <input
            type="text"
            maxlength="2"
            v-model="collectingEvent.start_date_day">
        </div>
        <div class="separate-left separate-right label-above">
          <label>Month</label>
          <input
            type="text"
            maxlength="2"
            v-model="collectingEvent.start_date_month">
        </div>
        <div class="separate-right label-above">
          <label>Year</label>
          <input
            id="start-date-year"
            type="text"
            maxlength="4"
            v-model="collectingEvent.start_date_year">
        </div>
        <div class="label-above">
          <label>&nbsp</label>
          <div class="horizontal-left-content">
            <button
              type="button"
              class="button normal-input button-default separate-right">
              Now
            </button>
            <button
              type="button"
              class="button normal-input button-default">
              Clone
            </button>
          </div>
        </div>
      </div>
    </div>
    <div>
      <label class="separate-bottom"><b>End date</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="label-above">
          <label>Day</label>
          <input
            type="text"
            maxlength="2"
            v-model="collectingEvent.end_date_day">
        </div>
        <div class="separate-left separate-right label-above">
          <label>Month</label>
          <input
            type="text"
            maxlength="2"
            v-model="collectingEvent.end_date_month">
        </div>
        <div class="separate-right label-above">
          <label>Year</label>
          <input
            type="text"
            maxlength="4"
            v-model="collectingEvent.end_date_year">
        </div>
        <div class="label-above">
          <label>&nbsp</label>
          <button
            type="button"
            class="button normal-input button-default">
            Now
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE]
}
</script>
