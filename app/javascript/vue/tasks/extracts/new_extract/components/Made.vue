<template>
  <div class="panel content">
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
          v-model="extract.year_made">
      </div>
      <div class="label-above">
        <label>Year</label>
        <input
          type="text"
          v-model="extract.month_made">
      </div>
      <div class="horizontal-left-content align-end">
        <button
          type="button"
          class="button normal-input button-default margin-small-right">
          Now
        </button>
        <button
          type="button"
          class="button normal-input button-default margin-small-right">
          Today
        </button>
        <button
          type="button"
          class="button normal-input button-default">
          This year
        </button>
        <lock-component/>
      </div>
    </div>
  </div>
</template>

<script>

import props from './mixins/props'
import LockComponent from 'components/lock'

export default {
  mixins: [props],
  components: {
    LockComponent
  }
}
</script>

<style>

</style>