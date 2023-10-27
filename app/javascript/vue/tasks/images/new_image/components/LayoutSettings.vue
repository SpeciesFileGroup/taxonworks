<template>
  <VBtn
    color="primary"
    medium
    @click="isModalVisible = true"
  >
    Layout
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Layout settings</h3>
    </template>
    <template #body>
      <label>
        <input
          type="checkbox"
          v-model="selectAll"
        />
        Panels
      </label>
      <hr />
      <VDraggable
        v-model="panelList"
        tag="ul"
        class="no_bullets"
        :item-key="(item) => item"
        @end="updateComponentPosition()"
      >
        <template #item="{ element }">
          <li>
            <label class="cursor-grab">
              <input
                type="checkbox"
                v-model="layout.panels"
                :value="element"
                @change="updateComponentPosition()"
              />
              {{ element }}
            </label>
          </li>
        </template>
      </VDraggable>
      <hr />
      <label>
        <input
          type="checkbox"
          v-model="layout.isStagePanelVisible"
        />
        Staged image
      </label>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import { sortArrayByArray } from '@/helpers/arrays.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VDraggable from 'vuedraggable'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },

  list: {
    type: Array,
    default: () => []
  }
})

const isModalVisible = ref(false)
const panelList = ref([...props.list])

const emit = defineEmits(['update:modelValue', 'update:panelSqed'])

const layout = computed({
  get: () => props.modelValue,
  set: (value) => {
    emit('update:modelValue', value)
  }
})

const selectAll = computed({
  get: () => panelList.value.length === props.modelValue.panels.length,
  set: (value) => {
    layout.value.panels = value ? panelList.value.map((item) => item) : []
  }
})

const updateComponentPosition = () => {
  const usedComponents = panelList.value.filter((item) =>
    layout.value.panels.includes(item)
  )

  layout.value.panels = sortArrayByArray(
    layout.value.panels,
    usedComponents,
    true
  )
}
</script>
