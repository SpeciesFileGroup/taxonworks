
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
        pin-section="GeographicAreas"
        pin-type="GeographicArea"
        @selected="sendGeographic"
      />
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import CRUD from '../../request/crud'

export default {
  mixins: [CRUD],
  components: {
    SmartSelector
  },
  data () {
    return {
      smartGeographics: [],
      selected: undefined,
      lock: false
    }
  },
  methods: {
    sendGeographic (item) {
      this.selected = ''
      this.$emit('select', item.id)
    }
  }
}
</script>
