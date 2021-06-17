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
import { GetterNames } from '../../../../store/getters/getters.js'
import { MutationNames } from '../../../../store/mutations/mutations.js'

export default {
  components: {
    PredicatesComponent
  },
  computed: {
    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    },
    projectPreferences () {
      return this.$store.getters[GetterNames.GetProjectPreferences]
    }
  },
  methods: {
    setAttributes (dataAttributes) {
      this.$store.commit(MutationNames.SetCollectionEventDataAttributes, dataAttributes)
    }
  }
}
</script>
