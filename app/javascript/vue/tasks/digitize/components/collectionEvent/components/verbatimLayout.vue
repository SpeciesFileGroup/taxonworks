<template>
  <div class="verbatim-layout">
    <h2>Verbatim</h2>
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

import VerbatimColectors from './verbatim/collectors.vue'
import VerbatimLabel from './verbatim/label.vue'
import VerbatimDate from './verbatim/date.vue'
import VerbatimDatum from './verbatim/datum.vue'
import VerbatimElevation from './verbatim/elevation.vue'
import VerbatimGeolocation from './verbatim/geolocationUncertainty.vue'
import VerbatimHabitat from './verbatim/habitat.vue'
import VerbatimLatitude from './verbatim/latitude.vue'
import VerbatimLocality from './verbatim/locality.vue'
import VerbatimLongitude from './verbatim/longitude.vue'
import VerbatimMethod from './verbatim/method.vue'
import sortComponent from '../../shared/sortComponenets.vue'

import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'

export default {
  mixins: [sortComponent],
  components: {
    Draggable,
    VerbatimColectors,
    VerbatimLabel,
    VerbatimMethod,
    VerbatimDate,
    VerbatimDatum,
    VerbatimElevation,
    VerbatimGeolocation,
    VerbatimHabitat,
    VerbatimLatitude,
    VerbatimLocality,
    VerbatimLongitude
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
  data() {
    return {
      componentsOrder: [
        'VerbatimLabel',
        'VerbatimLocality',
        'VerbatimLatitude',
        'VerbatimLongitude',
        'VerbatimGeolocation',
        'VerbatimElevation',
        'VerbatimHabitat',
        'VerbatimDate',
        'VerbatimColectors',
        'VerbatimMethod'
      ],
      keyStorage: 'tasks::digitize::verbatimOrder'
    }
  },
}
</script>

<style lang="scss">
  .verbatim-layout {
    label {
      display: block;
    }
    input[type="text"], textarea {
      width: 100%;
    }
  }
</style>