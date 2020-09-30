<template>
  <div>
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
    }
  },
  watch: {
    filter: {
      handler (newVal) {
        this.$store.dispatch(ActionNames.LoadUpdatedRemaining)
      },
      deep: true
    }
  },
  methods: {
    componentName (type) {
      return `${type.split('::').pop()}Descriptor`
    }
  }
}
</script>
