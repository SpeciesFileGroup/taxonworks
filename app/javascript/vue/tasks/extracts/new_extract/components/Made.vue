<template>
  <div>
    <h2>Made</h2>
    <div class="horizontal-left-content align-end">
      <div class="label-above margin-small-right">
        <label>Day</label>
        <input
          type="text"
          v-model="extract.day_made">
      </div>
      <div class="label-above margin-small-right">
        <label>Month</label>
        <input
          type="text"
          v-model="extract.month_made">
      </div>
      <div class="label-above">
        <label>Year</label>
        <input
          type="text"
          v-model="extract.year_made">
      </div>
      <div class="horizontal-left-content align-end margin-small-left">
        <button
          type="button"
          class="button normal-input button-default margin-small-right"
          @click="setActualDate">
          Now
        </button>
        <button
          type="button"
          class="button normal-input button-default"
          @click="setYear">
          This year
        </button>
        <lock-component/>
      </div>
    </div>
  </div>
</template>

<script>

import LockComponent from 'components/lock'
import componentExtend from './mixins/componentExtend'

export default {
  mixins: [componentExtend],
  components: {
    LockComponent
  },

  methods: {
    setActualDate () {
      const today = new Date()
      this.extract.day_made = today.getDate()
      this.extract.month_made = today.getMonth() + 1
      this.extract.year_made = today.getFullYear()
    },
    setYear () {
      const today = new Date()
      this.extract.year_made = today.getFullYear()
    }
  }
}
</script>
