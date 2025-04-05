<template>
  <div>
    <div class="horizontal-left-content separate-bottom">
      <VSwitch
        :options="Object.values(SHAPE_OPTIONS)"
        v-model="view"
      />
      <slot name="tabs-right" />
    </div>

    <div v-if="minimal">
      <VAutocomplete
        v-if="view == SHAPE_OPTIONS.GeographicArea"
        url="/geographic_areas/autocomplete"
        placeholder="Search for a geographic area"
        label="label_html"
        clear-after
        param="term"
        @get-item="(item) => sendMinimalGeographicArea(item.id)"
        class="separate-bottom"
      />

      <VAutocomplete
        v-else
        url="/gazetteers/autocomplete"
        placeholder="Search for a gazetteer"
        label="label_html"
        clear-after
        param="term"
        @get-item="(item) => sendMinimalGazetteer(item.id)"
        class="separate-bottom"
      />

    </div>

    <div v-else>
      <SmartSelector
        v-if="view == SHAPE_OPTIONS.GeographicArea"
        v-model="selectorModelShape"
        placeholder="Search for a geographic area"
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
        placeholder="Search for a gazetteer"
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
  </div>
</template>

<script setup>
import { Gazetteer, GeographicArea } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector'
import MapShapePicker from '@/components/ui/SmartSelector/MapShapePicker.vue'
import VAutocomplete from '@/components/ui/Autocomplete'
import VSwitch from '@/components/ui/VSwitch'

const SHAPE_OPTIONS = {
  GeographicArea: 'Geographic Area',
  Gazetteer: 'Gazetteer'
}

const props = defineProps({
  minimal: {
    type: Boolean,
    default: false
  },
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

function sendMinimalGeographicArea(id) {
  GeographicArea.find(id)
    .then(({ body }) => {
      body.shapeType = 'GeographicArea'
      sendShape(body)
    })
    .catch(() => {})
}

function sendMinimalGazetteer(id) {
  Gazetteer.find(id)
    .then(({ body }) => {
      body.shapeType = 'Gazetteer'
      sendShape(body)
    })
    .catch(() => {})
}

function sendGazetteer(shape) {
  shape.shapeType = 'Gazetteer'
  sendShape(shape)
}

function sendShape(shape) {
  emit('selectShape', shape)
  if (props.focusOnSelect) {
    smartSelector.value?.setFocus()
  }
}

</script>
