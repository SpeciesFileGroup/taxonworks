<template>
  <div class="position-absolute">
    <VBtn
      color="primary"
      @click="isModalVisible = true"
    >
      #
    </VBtn>
    <modal-component
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>Quick grid</h3>
      </template>
      <template #body>
        <fieldset>
          <legend>Quick grid</legend>
          <div class="flex-separate middle">
            <div class="horizontal-left-content middle">
              <div class="margin-small-right">
                <label>Rows:</label>
                <input
                  class="grid-input"
                  v-model="rows"
                  type="number"
                />
              </div>
              <div class="margin-small-right">
                <label>Columns:</label>
                <input
                  class="grid-input"
                  v-model="columns"
                  type="number"
                />
              </div>
              <button
                class="button normal-input button-default"
                @click="createGrid"
              >
                Set
              </button>
            </div>
            <div class="horizontal-left-content margin-medium-left">
              <button
                class="button normal-input button-default margin-small-right"
                @click="setGrid(10, 2)"
              >
                10x2
              </button>
              <button
                class="button normal-input button-default margin-small-right"
                @click="setGrid(10, 3)"
              >
                10x3
              </button>
              <button
                class="button normal-input button-default"
                @click="setGrid(1, 1)"
              >
                1x1
              </button>
            </div>
          </div>
        </fieldset>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ModalComponent from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  height: {
    type: Number,
    required: true
  },
  width: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['grid'])

const rows = ref(1)
const columns = ref(1)
const isModalVisible = ref(false)

function createGrid() {
  const wSize = props.width / columns.value
  const hSize = props.height / rows.value
  const vlines = segments(wSize, columns.value)
  const hlines = segments(hSize, rows.value)

  emit('grid', { vlines, hlines })
}

function segments(size, parts) {
  const segments = []

  for (let i = 0; i <= parts; i++) {
    segments.push(size * i)
  }
  return segments
}

function setGrid(r, c) {
  columns.value = c
  rows.value = r
  createGrid()
}
</script>

<style lang="scss" scoped>
:deep(.modal-container) {
  width: 500px;
}

.grid-input {
  width: 50px;
}
</style>
