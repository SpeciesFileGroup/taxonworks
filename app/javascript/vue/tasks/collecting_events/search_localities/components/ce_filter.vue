<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div>
      <h2>Date - exact match</h2>
      <div>
        <label>
          <b>Start date</b>
        </label>
        <div class="horizontal-left-content separate-bottom">
          <div class="separate-right">
            <label>Day</label>
            <input
              class="date-input"
              v-model="parameters.start_date_day"
              type="text"
              maxlength="2">
          </div>
          <div class="separate-left separate-right">
            <label>Month</label>
            <month-select
              class="date-input"
              @month="parameters.start_date_month = $event"/>
          </div>
          <div class="separate-left">
            <label>Year</label>
            <input
              class="date-input"
              v-model="parameters.start_date_year"
              type="text"
              maxlength="4">
          </div>
        </div>
      </div>
      <div>
        <label>
          <b>End date</b>
        </label>
        <div class="horizontal-left-content separate-bottom">
          <div class="separate-right">
            <label>Day</label>
            <input
              class="date-input"
              v-model="parameters.end_date_day"
              type="text"
              maxlength="2">
          </div>
          <div class="separate-left separate-right">
            <label>Month</label>
            <month-select
              class="date-input"
              @month="parameters.end_date_month = $event"/>
          </div>
          <div class="separate-left">
            <label>Year</label>
            <input
              class="date-input"
              v-model="parameters.end_date_year"
              type="text"
              maxlength="4">
          </div>
        </div>
      </div>
      <h2>Date between</h2>
      <div class="field">
        <input
          id="vueStartDate"
          v-model="parameters.start_date"
          type="date">
        <button
          type="button"
          class="button normal-input button-default separate-left"
          @click="setTodaysDateForStart">
          Now
        </button>
      </div>
      <div>
        <input
          id="vueEndDate"
          v-model="parameters.end_date"
          type="date">
        <button
          type="button"
          class="button normal-input button-default separate-left"
          @click="setTodaysDateForEnd">
          Now
        </button>
      </div>    
    </div>
    <h2>Matching fields</h2>
    <div class="field">
      <label>Verbatim locality containing</label>
      <input
        v-model="parameters.in_verbatim_locality"
        type="text"
        size="35">
    </div>
    <div class="field">
      <label>Any label containing</label>
      <input
        v-model="parameters.in_labels"
        type="text"
        size="35">
    </div>
    <h2>Matching identifier</h2>
    <div class="field">
      <label>An identifier containing</label>
      <input
        v-model="parameters.identifier_text"
        type="text"
        size="35">
    </div>
    <input
      class="button normal-input button-default separate-left"
      type="button"
      @click="getFilterData()"
      :disabled="!haveParams"
      value="Find"
    >
  </div>
</template>
<script>
import MonthSelect from './month_select'
import Spinner from 'components/spinner'
import { CollectingEvent } from 'routes/endpoints'

export default {
  components: {
    MonthSelect,
    Spinner
  },

  data () {
    return {
      parameters: {
        start_date_day: '',
        end_date_day: '',
        start_date_month: '',
        end_date_month: '',
        start_date_year: '',
        end_date_year: '',
        start_date: '',
        end_date: '',
        in_verbatim_locality: '',
        in_labels: '',
        identifier_text: '',
        shape: ''
      },
      collectingEventList: [],
      isLoading: false,
      haveParams: false
    }
  },

  watch: {
    parameters: {
      handler () {
        this.disableFind()
      },
      deep: true
    }
  },

  methods: {
    setTodaysDateForStart () {
      this.parameters.start_date = this.makeISODate(new Date())
    },

    setTodaysDateForEnd () {
      this.parameters.end_date = this.makeISODate(new Date())
    },

    getFilterData () {
      const params = {}
      const keys = Object.keys(this.parameters)

      for (let i=0; i<keys.length; i++) {
        if (this.parameters[keys[i]].length) {
          params[keys[i]] = this.parameters[keys[i]]
        }
      }
      this.isLoading = true
      CollectingEvent.where(params).then(response => {
        this.collectingEventList = response.body
        this.$emit('jsonUrl', response.request.responseURL)
        if (this.collectingEventList) {
          this.$emit('collectingEventList', this.collectingEventList)
        }
        this.isLoading = false
      })
    },

    makeISODate (date) {
      return date.toISOString().slice(0,10)
    },

    disableFind () {
      let count = 0
      Object.values(this.parameters).forEach(param => {
        count += param.length
      })
      this.haveParams = (count > 0)
    }
  }
}
</script>
<style scoped>
  label {
    display: block;
  }
  .date-input {
    max-width: 60px;
  }
</style>
