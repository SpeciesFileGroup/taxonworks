<template>
  <div>
    <template v-if="descriptorsUsed.length">
      <h3>Used Characters</h3>
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
      <h3>Characters Useful for Identification</h3>
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
      <h3>Characters no longer relevant for identification</h3>
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
  methods: {
    componentName (type) {
      return `${type.split('::').pop()}Descriptor`
    }
  }
}
</script>
