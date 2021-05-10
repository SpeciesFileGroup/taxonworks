<template>
  <block-layout>
    <h3 slot="header">Custom attributes</h3>
    <custom-attributes
      v-if="projectPreferences"
      slot="body"
      :object-id="extractId"
      object-type="Extract"
      model="Extract"
      :model-preferences="projectPreferences.model_predicate_sets.Extract"
      @onUpdate="setAttributes"
    />
  </block-layout>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import CustomAttributes from 'components/custom_attributes/predicates/predicates'
import componentExtend from './mixins/componentExtend'
import BlockLayout from 'components/blockLayout.vue'

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
