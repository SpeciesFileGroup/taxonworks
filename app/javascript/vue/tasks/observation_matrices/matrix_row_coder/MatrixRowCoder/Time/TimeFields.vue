<template>
  <DateFields
    :inline="inline"
    v-model:day="day"
    v-model:month="month"
    v-model:year="year"
  />
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations'
import DateFields from 'components/ui/Date/DateFields.vue'

export default {
  components: { DateFields },

  props: {
    descriptor: {
      type: Object,
      required: true
    },

    observation: {
      type: Object,
      required: true
    },

    inline: {
      type: Boolean,
      default: false
    }
  },

  computed: {
    day: {
      get () {
        return this.observation.day
      },
      set (day) {
        this.$store.commit(MutationNames.SetDayFor, {
          descriptorId: this.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          day
        })
      }
    },

    month: {
      get () {
        return this.observation.month
      },
      set (month) {
        this.$store.commit(MutationNames.SetMonthFor, {
          descriptorId: this.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          month
        })
      }
    },

    year: {
      get () {
        return this.observation.year
      },
      set (year) {
        this.$store.commit(MutationNames.SetYearFor, {
          descriptorId: this.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          year
        })
      }
    }
  }
}
</script>
