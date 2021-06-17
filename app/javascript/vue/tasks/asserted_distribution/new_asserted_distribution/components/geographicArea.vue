<template>
  <fieldset>
    <legend>Geographic area</legend>
    <smart-selector
      v-model="assertedDistribution.geographicArea"
      model="geographic_areas"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      ref="smartSelector"
      label="name"
      pin-section="GeographicAreas"
      @selected="onSelect"
      pin-type="GeographicArea">
      <template v-if="assertedDistribution.geographicArea">
        <p class="horizontal-left-content">
          <span data-icon="ok"/>
          <span v-html="assertedDistribution.geographicArea.name"/>
          <span
            class="button circle-button btn-undo button-default"
            @click="unset"/>
        </p>
      </template>
    </smart-selector>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'

export default {
  components: { SmartSelector },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    }
  },

  emits: [
    'update:modelValue',
    'selected'
  ],

  computed: {
    assertedDistribution: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    refresh () {
      this.$refs.smartSelector.refresh()
    },
    unset () {
      this.assertedDistribution.geographicArea = undefined
    },
    onSelect (geo) {
      this.assertedDistribution.geographicArea = geo
      this.$emit('selected')
    }
  }
}
</script>