<template>
  <div>
    <template v-if="rowFilter.length">
      <label>
        <input
          v-model="settings.rowFilter"
          type="checkbox">
        Filter
      </label>
    </template>
    <template v-if="descriptorsUsed.length">
      <h3>Used Descriptors</h3>
      <ol>
        <li
          v-for="descriptor in descriptorsUsed"
          :key="descriptor.id">
          <component
            :descriptor="descriptor"
            v-model="filter"
            :is="componentName(descriptor.type)"/>
        </li>
      </ol>
    </template>
    <template v-if="descriptorsUseful.length">
      <h3>Descriptors Useful for Identification</h3>
      <ol>
        <li
          v-for="descriptor in descriptorsUseful"
          :key="descriptor.id">
          <component
            :descriptor="descriptor"
            v-model="filter"
            :is="componentName(descriptor.type)"/>
        </li>
      </ol>
    </template>
    <template v-if="descriptorsUseless.length">
      <h3>Descriptors no longer relevant for identification</h3>
      <ol>
        <li
          v-for="descriptor in descriptorsUseless"
          :key="descriptor.id">
          <component
            :descriptor="descriptor"
            v-model="filter"
            :is="componentName(descriptor.type)"/>
        </li>
      </ol>
    </template>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

import ContinuousDescriptor from './Descriptors/Continuous'
import SampleDescriptor from './Descriptors/Sample'
import QualitativeDescriptor from './Descriptors/Qualitative'
import PresenceAbsenceDescriptor from './Descriptors/PresenceAbsence'

export default {
  components: {
    ContinuousDescriptor,
    SampleDescriptor,
    QualitativeDescriptor,
    PresenceAbsenceDescriptor
  },
  computed: {
    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },
    descriptors () {
      return this.$store.getters[GetterNames.GetObservationMatrix] ? this.$store.getters[GetterNames.GetObservationMatrix].list_of_descriptors : []
    },
    descriptorsUsed () {
      return this.descriptors.filter(d => d.status === 'used')
    },
    descriptorsUseless () {
      return this.descriptors.filter(d => d.status === 'useless')
    },
    descriptorsUseful () {
      return this.descriptors.filter(d => d.status === 'useful')
    },
    filter: {
      get () {
        return this.$store.getters[GetterNames.GetDescriptorsFilter]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDescriptorsFilter, value)
      }
    },
    filters () {
      return this.$store.getters[GetterNames.GetParamsFilter]
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings)
      }
    },
    rowFilter () {
      return this.$store.getters[GetterNames.GetRowFilter]
    },
    settingRowFilter () {
      return this.settings.rowFilter
    }
  },
  watch: {
    filter: {
      handler (newVal) {
        this.refreshKey()
      },
      deep: true
    },
    filters: {
      handler (newVal) {
        this.loadMatrix()
      },
      deep: true
    },
    settingRowFilter: {
      handler (newVal) {
        this.loadMatrix()
      }
    }
  },
  methods: {
    componentName (type) {
      return `${type.split('::').pop()}Descriptor`
    },
    refreshKey () {
      if (this.settings.refreshOnlyTaxa) {
        this.$store.dispatch(ActionNames.LoadUpdatedRemaining)
      } else {
        this.$store.dispatch(ActionNames.LoadObservationMatrix, this.observationMatrix.observation_matrix_id)
        document.querySelector('.descriptors-view div').scrollIntoView(0)
      }
    },
    loadMatrix () {
      this.$store.dispatch(ActionNames.LoadObservationMatrix, this.observationMatrix.observation_matrix_id)
    }
  }
}
</script>
