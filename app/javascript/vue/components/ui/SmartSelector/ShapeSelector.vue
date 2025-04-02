<template>
  <div>
    <div class="horizontal-left-content">
      <VSwitch
        :options="Object.values(SHAPE_OPTIONS)"
        v-model="view"
      />
      <slot name="tabs-right" />
    </div>

    <SmartSelector
      v-if="view == SHAPE_OPTIONS.GeographicArea"
      v-model="selectorModelShape"
      model="geographic_areas"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      label="name"
      ref="smartSelector"
      :add-tabs="['map']"
      inline
      pin-section="GeographicAreas"
      pin-type="GeographicArea"
      @selected="(shape) => sendGeographicArea(shape)"
    >
      <template #map>
        <MapShapePicker
          @select="(shape) => sendGeographicArea(shape)"
        />
      </template>
    </SmartSelector>

    <SmartSelector
      v-else
      v-model="selectorModelShape"
      model="gazetteers"
      klass="AssertedDistribution"
      target="AssertedDistribution"
      label="name"
      ref="smartSelector"
      :add-tabs="['map']"
      inline
      pin-section="Gazetteers"
      pin-type="Gazetteer"
      @selected="(shape) => sendGazetteer(shape)"
    >
      <template #map>
        <MapShapePicker
          :shape-endpoint="Gazetteer"
          @select="(shape) => sendGazetteer(shape)"
        />
      </template>
    </SmartSelector>
  </div>
</template>

<script setup>
import { Gazetteer } from '@/routes/endpoints'
import { computed, ref } from 'vue'
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

const inputShape = defineModel({type: Object, default: () => {}})

const emit = defineEmits(['selectShape'])

const smartSelector = ref(null)
const view = ref(SHAPE_OPTIONS.GeographicArea)

// inputShape gets passed on to the selector if they have the same shape type;
// shape assigned from the selector *always* gets passed back to inputShape.
const selectorModelShape = computed({
  get() {
    return inputShape.value?.shapeType == viewClass.value
      ? inputShape.value
      : {}
  },
  set(value) {
    value.type = view.value
    inputShape.value = value
  }
})

const viewClass = computed(() => {
  return view.value == 'Geographic Area' ? 'GeographicArea' : view.value
})

function sendGeographicArea(shape) {
  shape.shapeType = 'GeographicArea'
  sendShape(shape)
}

function sendGazetteer(shape) {
  shape.shapeType = 'Gazetteer'
  sendShape(shape)
}

function sendShape(shape) {
  emit('selectShape', shape)
  if (props.focusOnSelect) {
    smartSelector.value.setFocus()
  }
}

</script>
