<template>
  <div>
    <div class="flex-col full_width full_height">
      <div class="horizontal">
        <VSwitch
          :options="currentOptions"
          v-model="view"
        />

        <VSwitch
          v-if="showMap"
          v-model="previewOperation"
          :options="['Union', 'Intersection']"
        />
      </div>

      <Leaflet
        v-if="showMap"
        height="100%"
        :shapes="[geojsonShape]"
        editing-disabled
      />

      <DisplayList
        v-else
        class="geolist right-column"
        :list="rawShapes"
        @delete="
          (shape) => {
            emit('deleteShape', shape)
          }
        "
      />
    </div>
  </div>
</template>

<script setup>
import DisplayList from './DisplayList.vue'
import Leaflet from './Leaflet.vue'
import VSwitch from '@/components/ui/VSwitch'
import { computed, ref, watch } from 'vue'

const PRESAVE_OPTIONS = {
  Preview: 'Shape preview',
  Table: 'Shapes table'
}

const props = defineProps({
  geojsonShape: {
    type: Object,
    default: () => ({})
  },

  rawShapes: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['deleteShape', 'previewing', 'operationIsUnion'])

const previewOperationIsUnion = defineModel({ type: Boolean, default: true })

const previewOperation = computed({
  get: () => (previewOperationIsUnion.value ? 'Union' : 'Intersection'),
  set: (value) => {
    previewOperationIsUnion.value = value === 'Union'
  }
})

const view = ref(PRESAVE_OPTIONS.Preview)

const currentOptions = computed(() => {
  return Object.values(PRESAVE_OPTIONS)
})

const showMap = computed(() => {
  return view.value == PRESAVE_OPTIONS.Preview
})

watch(
  view,
  (newVal) => {
    emit('previewing', newVal == PRESAVE_OPTIONS.Preview)
  },
  { immediate: true }
)
</script>

<style scoped>
.horizontal {
  display: flex;
  gap: 1.5em;
}
</style>
