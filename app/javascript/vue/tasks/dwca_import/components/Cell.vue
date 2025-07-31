<template>
  <td v-if="isEditing">
    <div class="dwc-table-cell">
      <input
        ref="inputRef"
        class="full_width"
        @blur="
          () => {
            updateText()
            setEditMode(false)
          }
        "
        @keypress.enter="removeBlur"
        @keydown.esc="cancelEdit"
        v-model="currentText"
        type="text"
      />
    </div>
  </td>
  <td
    v-else
    style="height: 40px"
    @click="setEditMode"
  >
    <div class="dwc-table-cell">
      {{ currentText }}
    </div>
  </td>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue'

const props = defineProps({
  cell: {
    type: [String],
    default: undefined
  },
  cellIndex: {
    type: Number,
    required: true
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update'])

const isEditing = ref(false)
const initialText = ref()
const currentText = ref()
const inputRef = ref(null)

watch(
  () => props.cell,
  (newVal) => {
    currentText.value = newVal
  },
  { immediate: true }
)

function setEditMode(value) {
  if (props.disabled) return

  isEditing.value = value

  if (value) {
    initialText.value = currentText.value
    nextTick(() => {
      inputRef.value.focus()
    })
  }
}

function updateText() {
  if (initialText.value !== currentText.value) {
    emit('update', { [props.cellIndex]: currentText.value })
  }
}

function removeBlur() {
  document.activeElement.blur()
}

function cancelEdit() {
  isEditing.value = false
  currentText.value = initialText.value
}
</script>
