<template>
  <div>
    <div class="radial-annotator">
      <VModal
        v-if="isModalVisible"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <h3>Radial collection object</h3>
        </template>
        <template #body>
          <div class="flex-separate">
            <div class="radial-annotator-menu">
              <div>
                <radial-menu
                  :options="menuOptions"
                  @on-click="selectSlice"
                />
              </div>
            </div>
            <div
              class="radial-annotator-template panel"
              v-if="currentSlice"
            >
              <h2 class="view-title">
                {{ currentSlice }}
              </h2>
              <component
                :is="SLICES[currentSlice]"
                :ids="ids"
                :parameters="params"
                :count="count"
              />
            </div>
          </div>
        </template>
      </VModal>
      <VBtn
        class="circle-button"
        title="Radial collection object"
        circle
        color="radial"
        :disabled="disabled || (!ids.length && !Object.keys(params).length)"
        @click="isModalVisible = true"
      >
        <VIcon
          name="batch"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import RadialMenu from '@/components/radials/RadialMenu.vue'
import VModal from '@/components/ui/Modal.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import SliceTaxonDetermination from './components/SliceTaxonDetermination.vue'
import SliceBiocurations from './components/SliceBiocurations/SliceBiocurations.vue'
import SliceRepository from './components/SliceRepository.vue'
import DwcSlice from './components/DwCSlice.vue'

import { computed, ref } from 'vue'
import { removeEmptyProperties } from '@/helpers/objects.js'

const EXCLUDE_PARAMETERS = ['per', 'page', 'extend']
const SLICES = {
  'Add biocurations': SliceBiocurations,
  'Taxon determinations': SliceTaxonDetermination,
  Repository: SliceRepository,
  'Regenerate DwC': DwcSlice
}

defineOptions({
  name: 'RadialCollectionObject'
})

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  disabled: {
    type: Boolean,
    default: false
  },

  parameters: {
    type: Object,
    default: () => ({})
  },

  count: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['close'])
const isModalVisible = ref(false)
const currentSlice = ref(null)

const params = computed(() => {
  const parameters = removeEmptyProperties({
    ...props.parameters,
    collection_object_id: props.ids
  })

  EXCLUDE_PARAMETERS.forEach((param) => {
    delete parameters[param]
  })

  return removeEmptyProperties(parameters)
})

const menuOptions = computed(() => {
  const sliceName = Object.keys(SLICES)

  const slices = sliceName.map((type) => ({
    name: type,
    label: type,
    innerPosition: 1.7,
    svgAttributes: {
      class: currentSlice.value === type ? 'slice active' : 'slice'
    }
  }))

  return {
    width: 400,
    height: 400,
    sliceSize: 120,
    centerSize: 34,
    margin: 2,
    svgAttributes: {
      class: 'svg-radial-menu'
    },
    svgSliceAttributes: {
      fontSize: 11
    },
    slices
  }
})

function selectSlice({ name }) {
  currentSlice.value = name
}

function closeModal() {
  isModalVisible.value = false
  emit('close')
}
</script>
