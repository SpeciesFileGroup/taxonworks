<template>
  <CustomAttributes
    v-if="projectPreferences"
    ref="customAttributes"
    :object-id="collectingEvent.id"
    object-type="CollectingEvent"
    model="CollectingEvent"
    :model-preferences="projectPreferences.model_predicate_sets.CollectingEvent"
    @on-update="setAttributes"
  />
</template>

<script>
import CustomAttributes from '@/components/custom_attributes/predicates/predicates'
import extendCE from '../../mixins/extendCE.js'
import { GetterNames } from '../../../../store/getters/getters.js'
import { ActionNames } from '../../../../store/actions/actions.js'

export default {
  mixins: [extendCE],

  components: { CustomAttributes },

  computed: {
    projectPreferences() {
      return this.$store.getters[GetterNames.GetProjectPreferences]
    }
  },

  data() {
    return {
      unsubscribe: null
    }
  },

  created() {
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
      this.updateChange()
    }
  }
}
</script>
