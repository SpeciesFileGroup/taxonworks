<template>
  <div>
    <button
      :disabled="disabled"
      class="button normal-input button-default"
      @click="isModalVisible = true"
    >
      Enter coordinates
    </button>
    <modal-component
      v-if="isModalVisible"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>{{ title }}</h3>
      </template>
      <template #body>
        <div class="field label-above">
          <label>Latitude</label>
          <input
            type="text"
            v-model="shape.lat"
            ref="inputText"
          />
        </div>
        <div class="field label-above">
          <label>Longitude</label>
          <input
            type="text"
            v-model="shape.long"
          />
        </div>
        <div
          v-if="includeRange"
          class="field label-above"
        >
          <label>Range distance</label>
          <label
            v-for="range in RANGES"
            :key="range"
          >
            <input
              type="radio"
              name="georeference-distance"
              :value="range"
              v-model="shape.range"
            />
            {{ range }}
          </label>
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="normal-input button button-submit"
          :disabled="!validateFields"
          @click="createShape"
        >
          Add point
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import ModalComponent from '@/components/ui/Modal'
import convertDMS from '@/helpers/parseDMS.js'
import { computed, nextTick, ref, watch } from 'vue'

const RANGES = [0, 10, 100, 1000, 10000]

const props = defineProps({
  title: {
    type: String,
    default: 'Create georeference'
  },
  includeRange: {
    type: Boolean,
    default: true
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['create'])

const inputText = ref(null)

const validateFields = computed(
  () => convertDMS(shape.value.lat) && convertDMS(shape.value.long)
)
const isModalVisible = ref(false)
const shape = ref({})

function createShape() {
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

watch(isModalVisible, (newVal) => {
  if (newVal) {
    shape.value = {
      lat: undefined,
      long: undefined,
      range: 0
    }

    nextTick(() => {
      inputText.value.focus()
    })
  }
})
</script>

<style lang="scss" scoped>
:deep(.modal-container) {
  max-width: 300px;
}
</style>
