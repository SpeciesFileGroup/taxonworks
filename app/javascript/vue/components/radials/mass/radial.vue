<template>
  <div>
    <div class="radial-annotator">
      <VModal
        v-if="isRadialOpen"
        transparent
        @close="closeRadialBatch()"
      >
        <template #header>
          <h3 class="flex-separate">
            <span>Radial mass annotator</span>
            <span class="separate-right">
              {{ objectType }}
            </span>
          </h3>
        </template>
        <template #body>
          <div class="flex-separate">
            <VSpinner v-if="!Object.keys(annotatorTypes).length" />
            <div class="radial-annotator-menu">
              <div>
                <RadialMenu
                  :options="menuOptions"
                  @click="selectSlice"
                />
              </div>
            </div>
            <div
              class="radial-annotator-template panel"
              v-if="currentSliceName"
            >
              <h2 class="capitalize view-title">
                {{ currentSliceName }}
              </h2>
              <component
                :is="currentSlice"
                :object-type="objectType"
                :ids="ids"
                :parameters="params"
                :nested-query="nestedQuery"
                @create="
                  () => {
                    RadialAnnotatorEventEmitter.emit('reset')
                  }
                "
              />
            </div>
          </div>
        </template>
      </VModal>
      <VBtn
        class="circle-button"
        title="Radial mass annoator"
        circle
        color="radial"
        :disabled="disabled || (!ids.length && !Object.keys(params).length)"
        @click="openRadialBatch"
      >
        <VIcon
          name="radialMassAnnotator"
          title="Radial mass annoator"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import RadialMenu from '@/components/radials/RadialMenu.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { useRadialBatch } from '@/components/radials/shared/useRadialBatch'
import { RadialAnnotatorEventEmitter } from '@/utils/index.js'
import { ANNOTATORS } from './constants/annotators.js'
import { Metadata } from '@/routes/endpoints'
import { ref, onBeforeMount } from 'vue'

const EXCLUDE_PARAMETERS = ['per', 'page', 'extend']

defineOptions({
  name: 'RadialMassAnnotator'
})

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  },

  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    default: undefined
  },

  nestedQuery: {
    type: Boolean,
    default: false
  }
})

const {
  closeRadialBatch,
  currentSlice,
  currentSliceName,
  isRadialOpen,
  menuOptions,
  openRadialBatch,
  params,
  selectSlice
} = useRadialBatch({
  excludeParameters: EXCLUDE_PARAMETERS,
  props,
  slices: props.nestedQuery ? ANNOTATORS.all : ANNOTATORS.ids
})

const annotatorTypes = ref({})

onBeforeMount(() => {
  Metadata.annotators().then(({ body }) => {
    annotatorTypes.value = body
  })
})
</script>
