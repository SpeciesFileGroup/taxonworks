<template>
  <div class="panel content">
    <div class="field label-above">
      <h3>Pixels to CM</h3>
      <div class="flex flex-row gap-small">
        <input
          class="full_width"
          type="number"
          v-model="store.currentPixelsToCm"
        />
        <VBtn
          color="primary"
          medium
          @click="store.currentPixelsToCm = store.image.pixelsToCm"
        >
          Reset
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import useStore from '../../store/store.js'

const store = useStore()
</script>
