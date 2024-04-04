<template>
  <div>
    <VBtn
      color="primary"
      medium
      @click="setModalView(true)"
    >
      WKT coordinates
    </VBtn>
    <VModal
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
        <VBtn
          color="primary"
          medium
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
