<template>
  <div>
    <div class="radial-annotator">
      <VModal
        v-if="isRadialOpen"
        transparent
        @close="
          () => {
            closeRadialBatch()
            emit('close')
          }
        "
      >
        <template #header>
          <h3>{{ title }}</h3>
        </template>
        <template #body>
          <div class="flex-separate">
            <div class="radial-annotator-menu">
              <div>
                <RadialMenu
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
                {{ currentSliceName }}
              </h2>
              <component
                :is="currentSlice"
                :ids="ids"
                :parameters="params"
                :count="count"
                @close="
                  () => {
                    closeRadialBatch()
                    emit('close')
                  }
                "
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
        @click="openRadialBatch"
      >
        <VIcon
          :name="icon"
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
import { useRadialBatch } from '@/components/radials/shared/useRadialBatch'

const EXCLUDE_PARAMETERS = ['per', 'page', 'extend']

defineOptions({
  name: 'RadialBatch'
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
  },

  icon: {
    type: String,
    default: 'batch'
  },

  slices: {
    type: Object,
    default: () => ({})
  },

  title: {
    type: String,
    default: 'Radial batch'
  },

  objectType: {
    type: String,
    required: true
  },

  nestedQuery: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

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
  slices: props.slices
})
</script>
