<template>
  <div>
    <h2>Custom attributes</h2>
    <custom-attributes
      v-if="projectPreferences"
      :object-id="extractId"
      object-type="Extract"
      model="Extract"
      :model-preferences="projectPreferences.model_predicate_sets.Extract"
      @onUpdate="setAttributes"
    />
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import CustomAttributes from 'components/custom_attributes/predicates/predicates'
import componentExtend from './mixins/componentExtend'

export default {
  mixins: [componentExtend],

  components: { CustomAttributes },

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
