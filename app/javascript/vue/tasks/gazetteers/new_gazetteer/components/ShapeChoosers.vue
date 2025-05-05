<template>
  <div>
    <h2>Choose shapes</h2>

    <div class="shape-choose-buttons">
      <div>
        <button
          class="button normal-input button-default shrink-button"
          @click="() => (leafletVisible = true)"
        >
          From Leaflet
        </button>
      </div>

      <OtherInputs
        @new-shape="(data, type) => emit('newShape', data, type)"
      />

      <UnionInput
        @new-shape="(data, type) => emit('newShape', data, type)"
      />
    </div>

    <VModal
      v-if="leafletVisible"
      @close="() => (leafletVisible = false)"
      :container-style="{
        width: '80vw'
      }"
    >
      <template #header>
        <slot name="header"><h3>Draw shapes</h3></slot>
      </template>

      <template #body>
        <Leaflet
          :shapes="shapes"
          @shapes-updated="(shape) => emit('shapesUpdated', shape, GZ_LEAFLET)"
        />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import Leaflet from './Leaflet.vue'
import OtherInputs from './OtherInputs.vue'
import UnionInput from './UnionInput.vue'
import VModal from '@/components/ui/Modal.vue'
import {
  GZ_LEAFLET
} from '@/constants/index.js'
import { ref } from 'vue'

const props = defineProps({
  shapes: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['newShape', 'shapesUpdated'])

const leafletVisible = ref(false)

</script>

<style scoped>
.shape-choose-buttons {
  display: flex;
  flex-direction: column;
}

</style>