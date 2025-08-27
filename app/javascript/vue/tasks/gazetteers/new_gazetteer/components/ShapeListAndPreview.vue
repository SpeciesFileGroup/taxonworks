<template>
  <div>

    <div class="horizontal">
      <VSwitch
        :options="currentOptions"
        v-model="view"
      />

      <!--TODO: update VToggle so (Union == true) can be on the left.-->
      <VToggle
        v-if="showMap"
        v-model="previewOperationIsUnion"
        :options="['Union', 'Intersection']"
      />
    </div>

    <Leaflet
      v-if="showMap"
      :shapes="[geojsonShape]"
      :editing-disabled="true"
    />

    <DisplayList
      v-else
      class="geolist right-column"
      :list="rawShapes"
      @delete="(shape) => { emit('deleteShape', shape) }"
    />

  </div>
</template>

<script setup>
import DisplayList from './DisplayList.vue'
import Leaflet from './Leaflet.vue'
import VSwitch from '@/components/ui/VSwitch'
import VToggle from '@/tasks/observation_matrices/new/components/Matrix/switch.vue'
import { computed, ref, watch } from 'vue'

const PRESAVE_OPTIONS = {
  Preview: 'Shape preview',
  Table: 'Shapes table',
}

const props = defineProps({
  geojsonShape: {
    type: Object,
    default: () =>  ({})
  },

  rawShapes: {
    type: Array,
    default: () => []
  },
})

const emit = defineEmits(['deleteShape', 'previewing', 'operationIsUnion'])

const previewOperationIsUnion = defineModel({type: Boolean, default: true})

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
    emit('previewing',
      newVal == PRESAVE_OPTIONS.Preview
    )
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