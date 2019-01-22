<template>
  <predicates-component
    :object-id="collectingEvent.id"
    object-type="CollectingEvent"
    model="CollectingEvent"
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
    collectingEvent() {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    }
  },
  methods: {
    setAttributes(dataAttributes) {
      
      this.$store.commit(MutationNames.SetCollectionEventDataAttributes, dataAttributes)
      console.log(this.collectingEvent)
    }
  }
}
</script>
