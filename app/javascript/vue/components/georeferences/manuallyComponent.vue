<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="isModalVisible = true">Enter coordinates</button>
    <modal-component
      v-if="isModalVisible"
      @close="isModalVisible = false">
      <template #header>
        <h3>Create georeference</h3>
      </template>
      <template #body>
        <div class="field label-above">
          <label>Latitude</label>
          <input
            type="text"
            v-model="shape.lat">
        </div>
        <div class="field label-above">
          <label>Longitude</label>
          <input
            type="text"
            v-model="shape.long">
        </div>
        <div class="field label-above">
          <label>Range distance</label>
          <label
            v-for="range in RANGES"
            :key="range">
            <input
              type="radio"
              name="georeference-distance"
              :value="range"
              v-model="shape.range">
            {{ range }}
          </label>
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="normal-input button button-submit"
          :disabled="!validateFields"
          @click="createShape">
          Add point
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script setup>

import ModalComponent from 'components/ui/Modal'
import convertDMS from 'helpers/parseDMS.js'
import { computed, ref, watch } from 'vue'

const RANGES = [0, 10, 100, 1000, 10000]

const emit = defineEmits(['create'])

const validateFields = computed(() => convertDMS(shape.value.lat) && convertDMS(shape.value.long))
const isModalVisible = ref(false)
const shape = ref({})

const createShape = () => {
  const geoJson = {
    type: 'Feature',
    properties: { radius: shape.value.range || null },
    geometry: {
      type: 'Point',
      coordinates: [convertDMS(shape.value.long), convertDMS(shape.value.lat)]
    }
  }

  emit('create', geoJson)
  isModalVisible.value = false
}

watch(
  isModalVisible,
  newVal => {
    if (newVal) {
      shape.value = {
        lat: undefined,
        long: undefined,
        range: 0
      }
    }
  }
)

</script>

<style lang="scss" scoped>
  :deep(.modal-container) {
    max-width: 300px;
  }
</style>
