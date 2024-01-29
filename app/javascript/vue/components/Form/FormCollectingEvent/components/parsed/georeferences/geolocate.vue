<template>
  <div>
    <VBtn
      color="primary"
      medium
      @click="setModalView(true)"
    >
      GEOLocate
    </VBtn>
    <VModal
      v-if="isModalVisible"
      @close="setModalView(false)"
    >
      <template #header>
        <h3>GEOLocate</h3>
      </template>
      <template #body>
        <div class="field">
          <label>Coordinates:</label>
          <textarea
            class="full_width"
            rows="5"
            v-model="coordinates"
          />
        </div>
      </template>
      <template #footer>
        <VBtn
          color="primary"
          medium
          :disabled="!coordinates"
          @click="createShape"
        >
          Add
        </VBtn>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'
import { GEOREFERENCE_GEOLOCATE } from '@/constants/index.js'
import { ref } from 'vue'

const emit = defineEmits(['create'])

const isModalVisible = ref(false)
const coordinates = ref(null)

function createShape() {
  emit('create', {
    tmpId: Math.random().toString(36).substr(2, 5),
    iframe_response: coordinates.value,
    type: GEOREFERENCE_GEOLOCATE
  })

  setModalView(false)
}

function resetShape() {
  coordinates.value = null
}

function setModalView(value) {
  resetShape()
  isModalVisible.value = value
}
</script>
