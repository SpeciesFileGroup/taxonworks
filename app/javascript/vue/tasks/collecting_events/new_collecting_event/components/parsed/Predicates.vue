<template>
  <PredicatesComponent
    v-if="projectPreferences"
    :object-id="collectingEvent.id"
    object-type="CollectingEvent"
    model="CollectingEvent"
    ref="customAttributes"
    :model-preferences="projectPreferences.model_predicate_sets.CollectingEvent"
    @on-update="setAttributes"
  />
</template>

<script>
import { ActionNames } from '../../store/actions/actions.js'
import { Project } from '@/routes/endpoints'
import PredicatesComponent from '@/components/custom_attributes/predicates/predicates'
import extendCE from '../mixins/extendCE'

export default {
  mixins: [extendCE],

  components: {
    PredicatesComponent
  },

  data() {
    return {
      projectPreferences: undefined
    }
  },

  created() {
    Project.preferences().then((response) => {
      this.projectPreferences = response.body
    })

    this.$store.subscribeAction({
      after: (action) => {
        if (action.type === ActionNames.SaveCollectingEvent) {
          this.$refs.customAttributes.loadDataAttributes()
        }
      }
    })
  },

  beforeUnmount() {
    this.unsubscribe()
  },

  methods: {
    setAttributes(dataAttributes) {
      this.collectingEvent.data_attributes_attributes = dataAttributes
    }
  }
}
</script>
