<template>
  <div>
    <VSwitch
      :options="Object.values(SHAPE_OPTIONS)"
      v-model="view"
    />

    <SmartSelector
      v-if="view == SHAPE_OPTIONS.GeographicArea"
      model="geographic_areas"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      label="name"
      ref="smartSelector"
      :add-tabs="['map']"
      inline
      pin-section="GeographicAreas"
      pin-type="GeographicArea"
      @selected="(shape) => sendGeographicArea(shape.id)"
    >
      <template #map>
        <MapShapePicker
          @select="(shape) => sendGeographicArea(shape.id)"
        />
      </template>
    </SmartSelector>

    <SmartSelector
      v-else
      model="gazetteers"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      label="name"
      ref="smartSelector"
      :add-tabs="['map']"
      inline
      pin-section="Gazetteers"
      pin-type="Gazetteer"
      @selected="(shape) => sendGazetteer(shape.id)"
    >
      <template #map>
        <MapShapePicker
          :shape-endpoint="Gazetteer"
          @select="(shape) => sendGazetteer(shape.id)"
        />
      </template>
    </SmartSelector>
  </div>
</template>

<script setup>
import { Gazetteer } from '@/routes/endpoints'
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector'
import MapShapePicker from '@/components/ui/SmartSelector/MapShapePicker.vue'
import VSwitch from '@/components/ui/VSwitch'

const SHAPE_OPTIONS = {
  GeographicArea: 'Geographic Area',
  Gazetteer: 'Gazetteer'
}

const props = defineProps({
  focusOnSelect: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['selectShape'])

const smartSelector = ref(null)
const view = ref(SHAPE_OPTIONS.GeographicArea)

function sendGeographicArea(id) {
  sendShape({
    shapeType: 'GeographicArea',
    id
  })
}

function sendGazetteer(id) {
  sendShape({
    shapeType: 'Gazetteer',
    id
  })
}

function sendShape(shape) {
  emit('selectShape', shape)
  if (props.focusOnSelect) {
    smartSelector.value.setFocus()
  }
}

</script>
