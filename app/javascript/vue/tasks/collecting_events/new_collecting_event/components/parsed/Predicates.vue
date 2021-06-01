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

import { Project } from 'routes/endpoints'
import PredicatesComponent from 'components/custom_attributes/predicates/predicates'
import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],

  components: {
    PredicatesComponent
  },

  data () {
    return {
      projectPreferences: undefined
    }
  },

  created () {
    Project.preferences().then(response => {
      this.projectPreferences = response.body
    })
  },

  methods: {
    setAttributes (dataAttributes) {
      this.collectingEvent.data_attributes_attributes = dataAttributes
    }
  }
}
</script>
