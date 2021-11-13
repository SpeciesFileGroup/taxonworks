<template>
  <predicates-component
    v-if="projectPreferences"
    :object-id="collectingEvent.id"
    object-type="CollectingEvent"
    model="CollectingEvent"
    :model-preferences="projectPreferences.model_predicate_sets.CollectingEvent"
    @onUpdate="setAttributes"
  />
</template>

<script>

import PredicatesComponent from 'components/custom_attributes/predicates/predicates'
import extendCE from '../../mixins/extendCE.js'
import { GetterNames } from '../../../../store/getters/getters.js'

export default {
  mixins: [extendCE],

  components: { PredicatesComponent },

  computed: {
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    },

    projectPreferences () {
      return this.$store.getters[GetterNames.GetProjectPreferences]
    }
  },

  methods: {
    setAttributes (dataAttributes) {
      this.collectingEvent.data_attributes_attributes = dataAttributes
    }
  }
}
</script>
