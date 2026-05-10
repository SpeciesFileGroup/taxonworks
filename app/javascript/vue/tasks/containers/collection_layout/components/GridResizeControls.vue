<template>
  <div class="margin-medium-bottom horizontal-left-content gap-small flex-wrap">
    <label class="horizontal-left-content gap-xsmall middle">
      <input
        v-model.number="rowsBy"
        type="number"
        min="1"
        max="1000"
        class="w-12"
      />
      <VBtn
        color="update"
        medium
        :disabled="!rowsBy || saving"
        @click="resizeRows(+1)"
      >
        + rows
      </VBtn>
      <VBtn
        color="update"
        medium
        :disabled="!rowsBy || saving"
        @click="resizeRows(-1)"
      >
        - rows
      </VBtn>
    </label>

    <label class="horizontal-left-content gap-xsmall middle">
      <input
        v-model.number="colsBy"
        type="number"
        min="1"
        max="1000"
        class="w-12"
      />
      <VBtn
        color="update"
        medium
        :disabled="!colsBy || saving"
        @click="resizeCols(+1)"
      >
        + columns
      </VBtn>
      <VBtn
        color="update"
        medium
        :disabled="!colsBy || saving"
        @click="resizeCols(-1)"
      >
        - columns
      </VBtn>
    </label>

    <span
      v-if="error"
      class="feedback-warning"
      >{{ error }}</span
    >
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  container: {
    type: Object,
    default: null
  },
  saving: {
    type: Boolean,
    default: false
  },
  error: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['resize'])

const rowsBy = ref(1)
const colsBy = ref(1)

function resizeRows(direction) {
  if (!rowsBy.value || rowsBy.value < 1) return
  const current = props.container?.size_y || 0
  const newSize = current + direction * rowsBy.value
  if (newSize < 1) return
  emit('resize', { size_y: newSize })
}

function resizeCols(direction) {
  if (!colsBy.value || colsBy.value < 1) return
  const current = props.container?.size_x || 0
  const newSize = current + direction * colsBy.value
  if (newSize < 1) return
  emit('resize', { size_x: newSize })
}
</script>
