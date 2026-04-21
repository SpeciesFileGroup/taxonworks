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
          <div class="flex-row middle flex-separate">
            <h3>{{ title }}</h3>

            <label
              class="flex-row middle gap-xsmall margin-large-right"
              title="Automatically refreshes filter results after updating or adding records"
            >
              <input
                type="checkbox"
                v-model="autoRefresh"
              />
              Auto-refresh
            </label>
          </div>
        </template>
        <template #body>
          <div class="flex-separate">
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
                @close="handleClose"
              />
            </div>
          </div>
        </template>
      </VModal>
      <VBtn
        class="circle-button"
        :title="title"
        circle
        color="radial"
        :disabled="disabled || (!ids.length && !Object.keys(params).length)"
        @click="openRadialBatch"
      >
        <VIcon
          :name="icon"
          :title="title"
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
import { computed } from 'vue'
import { useRadialBatch } from '@/components/radials/shared/useRadialBatch'
import { useUserPreferences } from '@/composables'

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

const emit = defineEmits(['close', 'update'])

const STORAGE_KEY_AUTOREFRESH = 'RadialBatch::AutoRefresh'

const { preferences, setPreference } = useUserPreferences()

const autoRefresh = computed({
  get: () => preferences.value?.layout?.[STORAGE_KEY_AUTOREFRESH] ?? true,
  set: (value) => {
    setPreference(STORAGE_KEY_AUTOREFRESH, value)
  }
})

function handleClose() {
  closeRadialBatch()

  if (autoRefresh.value) {
    emit('update')
  }
}

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
