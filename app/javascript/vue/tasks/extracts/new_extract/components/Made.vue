<template>
  <block-layout>
    <template #header>
      <h3>Made</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-end">
        <div class="label-above margin-small-right">
          <label>Day</label>
          <input
            type="text"
            class="input-xsmall-width"
            v-model="extract.day_made">
        </div>
        <div class="label-above margin-small-right">
          <label>Month</label>
          <input
            type="text"
            class="input-xsmall-width"
            v-model="extract.month_made">
        </div>
        <div class="label-above">
          <label>Year</label>
          <input
            type="text"
            class="input-xsmall-width"
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
          <lock-component
            v-model="settings.lock.made"
            class="margin-small-left"/>
        </div>
      </div>
    </template>
  </block-layout>
</template>

<script>

import LockComponent from 'components/ui/VLock/index.vue'
import componentExtend from './mixins/componentExtend'
import BlockLayout from 'components/layout/BlockLayout'

export default {
  mixins: [componentExtend],

  components: {
    LockComponent,
    BlockLayout
  },

  methods: {
    setActualDate () {
      const today = new Date()
      this.extract.day_made = today.getDate()
      this.extract.month_made = today.getMonth() + 1
      this.extract.year_made = today.getFullYear()
    },

    setYear () {
      this.extract.day_made = undefined
      this.extract.month_made = undefined
      this.extract.year_made = (new Date()).getFullYear()
    }
  }
}
</script>
