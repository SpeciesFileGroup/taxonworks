<template>
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
      @selected="sendItem"/>
    <template v-if="selected">
      <p class="horizontal-left-content">
        <span data-icon="ok"/>
        <span v-html="selected"/>
        <span
          class="button circle-button btn-undo button-default"
          @click="unset"/>
      </p>
    </template>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  },
  props: {
    value: {}
  },
  data () {
    return {
      selected: undefined
    }
  },
  watch: {
    value (newVal) {
      if (newVal == undefined)
        this.selected = undefined
    }
  },
  methods: {
    sendItem(item) {
      this.setSelected(item)
      this.$emit('input', item.id)
    },
    setSelected(item) {
      this.selected = item.hasOwnProperty('label') ? item.label : item.name
    },
    refresh () {
      this.$refs.smartSelector.refresh()
    },
    unset () {
      this.$emit('input', undefined)
      this.selected = undefined
    }
  }
}
</script>