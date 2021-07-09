<template>
  <block-layout>
    <template #header>
      <h3>Custom attributes</h3>
    </template>
    <template #body>
      <custom-attributes
        v-if="projectPreferences"
        :object-id="extractId"
        object-type="Extract"
        model="Extract"
        :model-preferences="projectPreferences.model_predicate_sets.Extract"
        @onUpdate="setAttributes"
      />
    </template>
  </block-layout>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import CustomAttributes from 'components/custom_attributes/predicates/predicates'
import componentExtend from './mixins/componentExtend'
import BlockLayout from 'components/layout/BlockLayout'

export default {
  mixins: [componentExtend],

  components: {
    BlockLayout,
    CustomAttributes
  },

  computed: {
    projectPreferences () { return this.$store.getters[GetterNames.GetProjectPreferences] },

    extractId () { return this.$store.getters[GetterNames.GetExtract].id }
  },

  methods: {
    setAttributes (data) {
      this.extract.data_attributes_attributes = data
    }
  }
}
</script>
