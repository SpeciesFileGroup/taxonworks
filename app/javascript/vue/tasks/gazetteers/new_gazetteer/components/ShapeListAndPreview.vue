<template>
  <div>

    <div class="horizontal">
      <VSwitch
        :options="currentOptions"
        v-model="view"
      />

      <!--TODO: update VToggle so (Union == true) can be on the left.-->
      <VToggle
        v-if="!gzSaved && showMap"
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
      :editing-disabled="gzSaved"
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

const POSTSAVE_OPTIONS = {
  Shape: 'Saved shape',
  Table: 'Shape table'
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

  gzSaved: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['deleteShape', 'previewing', 'operationIsUnion'])

const previewOperationIsUnion = defineModel({type: Boolean, default: true})

const view = ref(props.gzSaved ? POSTSAVE_OPTIONS.Shape : PRESAVE_OPTIONS.Preview)

const currentOptions = computed(() => {
  return props.gzSaved ? Object.values(POSTSAVE_OPTIONS) : Object.values(PRESAVE_OPTIONS)
})

const showMap = computed(() => {
  return props.gzSaved
    ? view.value == POSTSAVE_OPTIONS.Shape
    : view.value == PRESAVE_OPTIONS.Preview
})

watch(
  view,
  (newVal) => {
    emit('previewing',
      newVal == PRESAVE_OPTIONS.Preview || newVal == POSTSAVE_OPTIONS.Shape
    )
  },
  { immediate: true }
)

watch(() => props.gzSaved, (newVal) => {
  if (newVal) {
    if (view.value == PRESAVE_OPTIONS.Preview) {
      view.value = POSTSAVE_OPTIONS.Shape
    } else if (view.value == PRESAVE_OPTIONS.Table) {
      view.value = POSTSAVE_OPTIONS.Table
    }
  } else {
    if (view.value == POSTSAVE_OPTIONS.Shape) {
      view.value = PRESAVE_OPTIONS.Preview
    } else if (view.value == POSTSAVE_OPTIONS.Table) {
      view.value = PRESAVE_OPTIONS.Table
    }
  }
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