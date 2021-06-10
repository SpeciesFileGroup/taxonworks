<template>
  <div class="geography-layout">
    <h2>Parsed</h2>
    <draggable
      v-model="componentsOrder"
      :disabled="!settings.sortable"
      :item-key="item => item"
      @end="updatePreferences">
      <template #item="{ element }">
        <component
          class="separate-bottom"
          :is="element"/>
      </template>
    </draggable>
  </div>
</template>
<script>

import Draggable from 'vuedraggable'

import Geography from './geography/geography.vue'
import Georeferences from './geography/georeferences.vue'
import Elevation from './geography/elevation.vue'
import Dates from './geography/dates.vue'
import Times from './geography/times.vue'
import Group from './geography/group.vue'
import Collectors from './geography/collectors.vue'
import Predicates from './geography/predicates.vue'
import sortComponent from '../../shared/sortComponenets.vue'
import TripCode from './geography/tripCode.vue'

import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'

export default {
  mixins: [sortComponent],
  components: {
    Draggable,
    Georeferences,
    Collectors,
    Geography,
    Elevation,
    Dates,
    Times,
    Group,
    Predicates,
    TripCode
  },
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      componentsOrder: ['Geography', 'Georeferences', 'Elevation', 'Dates', 'Times', 'Collectors', 'TripCode', 'Group', 'Predicates'],
      keyStorage: 'tasks::digitize::GeographyOrder'
    }
  }
}
</script>

<style lang="scss">
  .geography-layout {
    label {
      display: block;
    }
    li label {
      display: inline;
    }
  }
</style>
