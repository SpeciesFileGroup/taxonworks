<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="setModalView(true)"
    >
      WKT coordinates
    </button>
    <modal-component
      v-if="isModalVisible"
      @close="setModalView(false)"
    >
      <template #header>
        <h3>Create WKT georeference</h3>
      </template>
      <template #body>
        <div class="field label-above">
          <label>WKT data</label>
          <textarea
            class="full_width"
            rows="8"
            v-model="wkt"
          />
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="normal-input button button-submit"
          @click="createShape"
        >
          Add
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import ModalComponent from '@/components/ui/Modal'
import { GEOREFERENCE_WKT } from '@/constants/index.js'
import { ref } from 'vue'

const emit = defineEmits(['create'])

const isModalVisible = ref(false)
const wkt = ref(null)

function createShape() {
  emit('create', {
    tmpId: Math.random().toString(36).substr(2, 5),
    wkt: wkt.value,
    type: GEOREFERENCE_WKT
  })
  isModalVisible.value = false
}

function resetShape() {
  wkt.value = undefined
}

function setModalView(value) {
  resetShape()
  isModalVisible.value = value
}
</script>
