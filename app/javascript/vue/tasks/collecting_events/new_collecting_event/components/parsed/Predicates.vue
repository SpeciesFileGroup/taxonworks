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

import { GetProjectPreferences } from '../../request/resources'
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
  mounted () {
    GetProjectPreferences().then(response => {
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
