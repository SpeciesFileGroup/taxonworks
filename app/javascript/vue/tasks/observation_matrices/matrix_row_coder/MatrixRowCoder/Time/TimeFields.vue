<template>
  <div class="horizontal-left-content align-end">
    <v-btn
      v-if="!showDatafields"
      color="primary"
      circle
      @click="showDatafields = true"
    >
      <v-icon
        color="white"
        name="clock"
        small
      />
    </v-btn>
    <template v-if="showDatafields">
      <DateFields
        :inline="inline"
        time-field
        v-model:day="day"
        v-model:month="month"
        v-model:year="year"
        v-model:time="time"
      />
      <DateToday
        class="margin-small-right"
        v-model:day="day"
        v-model:month="month"
        v-model:year="year"
      />
      <DateNow
        v-model:day="day"
        v-model:month="month"
        v-model:year="year"
        v-model:time="time"
      />
    </template>
  </div>
</template>

<script>

import { MutationNames } from '../../store/mutations/mutations'
import DateFields from 'components/ui/Date/DateFields.vue'
import DateToday from 'components/ui/Date/DateToday.vue'
import DateNow from 'components/ui/Date/DateNow.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

export default {
  components: {
    DateFields,
    VBtn,
    VIcon,
    DateNow,
    DateToday
  },

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

  data: () => ({
    showDatafields: false
  }),

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
    },

    time: {
      get () {
        return this.observation.time
      },
      set (time) {
        this.$store.commit(MutationNames.SetTimeFor, {
          descriptorId: this.descriptor.id,
          observationId: this.observation.id || this.observation.internalId,
          time
        })
      }
    }
  }
}
</script>
