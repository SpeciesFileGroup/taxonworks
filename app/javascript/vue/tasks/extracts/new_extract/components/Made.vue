<template>
  <block-layout>
    <template #header>
      <h3>Made</h3>
    </template>
    <template #body>
      <div class="horizontal-left-content align-end">
        <date-fields
          v-model:year="extract.year_made"
          v-model:month="extract.month_made"
          v-model:day="extract.day_made"
        />
        <div class="horizontal-left-content align-end margin-small-left">
          <date-now
            v-model:year="extract.year_made"
            v-model:month="extract.month_made"
            v-model:day="extract.day_made"
          />
          <button
            type="button"
            class="button normal-input button-default margin-small-left"
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
import DateFields from 'components/ui/Date/DateFields.vue'
import DateNow from 'components/ui/Date/DateNow.vue'

export default {
  mixins: [componentExtend],

  components: {
    LockComponent,
    BlockLayout,
    DateFields,
    DateNow
  },

  methods: {
    setYear () {
      this.extract.day_made = undefined
      this.extract.month_made = undefined
      this.extract.year_made = (new Date()).getFullYear()
    }
  }
}
</script>
