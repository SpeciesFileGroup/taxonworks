<template>
  <div>
    <div class="radial-annotator">
      <VModal
        v-if="isModalVisible"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <h3>Radial Source</h3>
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
              />
            </div>
          </div>
        </template>
      </VModal>
      <VBtn
        class="circle-button"
        title="Radial Source"
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
import SliceSerial from './components/SliceSerial.vue'

import { computed, ref } from 'vue'
import { removeEmptyProperties } from '@/helpers/objects.js'

const EXCLUDE_PARAMETERS = ['per', 'page', 'extend']
const SLICES = {
  Serial: SliceSerial
}

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
const currentSlice = ref(Object.keys(SLICES)[0])

const params = computed(() => {
  const parameters = removeEmptyProperties({
    ...props.parameters,
    source_id: props.ids
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

<script>
export default {
  name: 'RadialSource'
}
</script>
