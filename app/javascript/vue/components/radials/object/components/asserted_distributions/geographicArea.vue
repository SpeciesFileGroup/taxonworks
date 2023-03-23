<template>
  <div>
    <fieldset>
      <legend>Geographic area</legend>
      <SmartSelector
        model="geographic_areas"
        klass="AssertedDistribution"
        target="AssertedDistribution"
        ref="smartSelector"
        label="name"
        :add-tabs="['map']"
        buttons
        inline
        pin-section="GeographicAreas"
        pin-type="GeographicArea"
        @selected="sendGeographic"
      >
        <template #map>
          <GeographicAreaMapPicker @select="sendGeographic" />
        </template>
      </SmartSelector>
    </fieldset>
  </div>
</template>

<script>
import SmartSelector from 'components/ui/SmartSelector'
import GeographicAreaMapPicker from 'components/ui/SmartSelector/GeographicAreaMapPicker.vue'

export default {
  components: {
    GeographicAreaMapPicker,
    SmartSelector
  },

  props: {
    sourceLock: {
      type: Boolean,
      required: true
    }
  },

  emits: ['select'],

  methods: {
    sendGeographic(item) {
      this.$emit('select', item.id)
      if (this.sourceLock) {
        this.$refs.smartSelector.setFocus()
      }
    }
  }
}
</script>
