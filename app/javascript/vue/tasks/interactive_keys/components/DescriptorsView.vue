<template>
  <div>
    <ol>
      <li
        v-for="descriptor in descriptors"
        :id="descriptor.id">
        <component
          :descriptor="descriptor"
          v-model="filter"
          :is="componentName(descriptor.type)"/>
      </li>
    </ol>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

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
    filter: {
      get () {
        return this.$store.getters[GetterNames.GetDescriptorsFilter]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDescriptorsFilter, value)
      }
    }
  },
  methods: {
    componentName (type) {
      return `${type.split('::').pop()}Descriptor`
    }
  }
}
</script>
