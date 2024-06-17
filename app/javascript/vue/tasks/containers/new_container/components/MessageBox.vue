<template>
  <div class="import-running-box">
    <transition name="bounce">
      <div
        v-if="store.placeItem"
        class="import-running-container panel content"
      >
        <div class="flex-separate middle gap-small">
          Click on an empty cell to place the container item
          <VBtn
            color="primary"
            @click="() => (store.placeItem = null)"
            >Cancel</VBtn
          >
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { useContainerStore } from '../store'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useContainerStore()
</script>

<style lang="scss" scoped>
.import-running-box {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
}
.import-running-container {
  background-color: white;
  transform-origin: center;
}
</style>
