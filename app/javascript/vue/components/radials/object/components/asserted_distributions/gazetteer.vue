<template>
  <div>
    <fieldset v-if="!disabled">
      <legend>Gazetteer</legend>
      <SmartSelector
        model="gazetteers"
        klass="AssertedDistribution"
        target="AssertedDistribution"
        ref="smartSelector"
        label="name"
        :add-tabs="['map']"
        buttons
        inline
        pin-section="Gazetteers"
        pin-type="Gazetteer"
        @selected="sendGazetteer"
      >
        <template #map>
          <MapShapePicker
            @select="sendGazetteer"
            :shape-endpoint="Gazetteer"
          />
        </template>
      </SmartSelector>
    </fieldset>
  </div>
</template>

<script setup>
import { Gazetteer } from '@/routes/endpoints'
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector'
// TODO: rename this component everywhere I guess
import MapShapePicker from '@/components/ui/SmartSelector/MapShapePicker.vue'

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

const emit = defineEmits(['selectGazetteer'])
const smartSelector = ref(null)

function sendGazetteer(item) {
  emit('selectGazetteer', item.id)
  if (props.sourceLock) {
    smartSelector.value.setFocus()
  }
}
</script>
