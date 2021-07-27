
<template>
  <div>
    <fieldset>
      <legend>Geographic area</legend>
      <smart-selector
        model="geographic_areas"
        klass="AssertedDistribution"
        target="AssertedDistribution"
        ref="smartSelector"
        label="name"
        :buttons="true"
        :inline="true"
        pin-section="GeographicAreas"
        pin-type="GeographicArea"
        @selected="sendGeographic"
      />
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import CRUD from '../../request/crud'

export default {
  mixins: [CRUD],

  components: { SmartSelector },

  props: {
    sourceLock: {
      type: Boolean,
      required: true
    }
  },

  emits: ['select'],

  data () {
    return {
      smartGeographics: [],
      selected: undefined
    }
  },

  methods: {
    sendGeographic (item) {
      this.selected = ''
      this.$emit('select', item.id)
      if (this.sourceLock) {
        this.$refs.smartSelector.setFocus()
      }
    }
  }
}
</script>
