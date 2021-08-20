<template>
  <div>
    <div class="horizontal-left-content align-end margin-small-bottom">
      <date-fields
        title="Start date"
        :fields="fieldStart"
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
        title="Start date"
        :fields="fieldEnd"
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

import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'

import DateFields from './Date/DateFields.vue'

export default {
  components: { DateFields },

  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionEvent, value)
      }
    }
  },

  data () {
    return {
      fieldStart: [
        {
          id: 'start-date-year',
          label: 'Year',
          property: 'start_date_year',
          maxLenght: 4
        },
        {
          label: 'Month',
          property: 'start_date_month',
          maxLenght: 2
        },
        {
          label: 'Day',
          property: 'start_date_day',
          maxLenght: 2
        }
      ],
      fieldEnd: [
        {
          label: 'Year',
          property: 'end_date_year',
          maxLenght: 4
        },
        {
          label: 'Month',
          property: 'end_date_month',
          maxLenght: 2
        },
        {
          label: 'Day',
          property: 'end_date_day',
          maxLenght: 2
        }
      ]
    }
  },

  methods: {
    setActualDateForStart() {
      const today = new Date()

      this.collectingEvent.start_date_day = today.getDate()
      this.collectingEvent.start_date_month = today.getMonth() + 1
      this.collectingEvent.start_date_year = today.getFullYear()
    },

    setActualDateForEnd() {
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
