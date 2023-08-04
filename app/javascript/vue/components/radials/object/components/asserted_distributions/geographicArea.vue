<template>
  <div>
    <VSpinner
      v-if="disabled"
      :show-legend="false"
      :show-spinner="false"
      z-index="2000"
    />
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

<script setup>
import { ref } from 'vue'
import VSpinner from '@/components/spinner.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import GeographicAreaMapPicker from '@/components/ui/SmartSelector/GeographicAreaMapPicker.vue'

const props = defineProps({
  sourceLock: {
    type: Boolean,
    required: true
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['select'])
const smartSelector = ref(null)

function sendGeographic(item) {
  emit('select', item.id)
  if (props.sourceLock) {
    smartSelector.value.setFocus()
  }
}
</script>
