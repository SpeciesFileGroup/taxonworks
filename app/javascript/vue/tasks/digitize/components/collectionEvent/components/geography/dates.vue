<template>
  <div>
    <div>
      <label class="separate-bottom"><b>Start date</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="separate-right">
          <label>Year</label>
          <input
            id="start-date-year"
            type="text"
            maxlength="4"
            v-model="startYear">
        </div>
        <div class="separate-right">
          <label>Month</label>
          <input
            type="text"
            maxlength="2"
            v-model="startMonth">
        </div>
        <div class="separate-right">
          <label>Day</label>
          <input
            type="text"
            maxlength="2"
            v-model="startDay">
        </div>
        <div>
          <label>&nbsp</label>
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
      </div>
    </div>
    <div>
      <label class="separate-bottom"><b>End date</b></label>
      <div class="horizontal-left-content separate-bottom">
        <div class="separate-right">
          <label>Year</label>
          <input
            type="text"
            maxlength="4"
            v-model="endYear">
        </div>
        <div class="separate-right">
          <label>Month</label>
          <input
            type="text"
            maxlength="2"
            v-model="endMonth">
        </div>
        <div class="separate-right">
          <label>Day</label>
          <input
            type="text"
            maxlength="2"
            v-model="endDay">
        </div>

        <div>
          <label>&nbsp</label>
          <button
            type="button"
            class="button normal-input button-default"
            @click="setActualDateForEnd">
            Now
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'

export default {
  computed: {
    startDay: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].start_date_day
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventStartDateDay, value)
      }
    },
    startMonth: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].start_date_month
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventStartDateMonth, value)
      }
    },
    startYear: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].start_date_year
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventStartDateYear, value)
      }
    },
    endDay: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].end_date_day
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventEndDateDay, value)
      }
    },
    endMonth: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].end_date_month
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventEndDateMonth, value)
      }
    },
    endYear: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].end_date_year
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventEndDateYear, value)
      }
    }
  },
  methods: {
    setActualDateForStart() {
      const today = new Date()

      this.startDay = today.getDate()
      this.startMonth = today.getMonth() + 1
      this.startYear = today.getFullYear()
    },
    setActualDateForEnd() {
      const today = new Date()

      this.endDay = today.getDate()
      this.endMonth = today.getMonth() + 1
      this.endYear = today.getFullYear()
    },
    cloneDate() {
      this.endDay = this.startDay
      this.endMonth = this.startMonth
      this.endYear = this.startYear
    }
  }
}
</script>

<style scoped>
  input {
    max-width: 60px;
  }
</style>
