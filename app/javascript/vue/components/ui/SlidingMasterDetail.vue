<template>
  <div class="smd-viewport">
    <div
      class="smd-slider"
      :class="{ 'smd-slider--show-detail': showDetail }"
    >
      <div class="smd-panel smd-panel--master">
        <slot
          name="master"
          :open-detail="openDetail"
        />
      </div>

      <div class="smd-panel smd-panel--detail">
        <slot
          name="detail"
          :close-detail="closeDetail"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const showDetail = ref(false)

function openDetail() {
  showDetail.value = true
}

function closeDetail() {
  showDetail.value = false
}

defineExpose({ openDetail, closeDetail })
</script>

<style scoped>
.smd-viewport {
  overflow: hidden;
  width: 100%;
}

.smd-slider {
  display: flex;
  width: 200%;
  transition: transform 0.3s ease;
  will-change: transform;
}

.smd-slider--show-detail {
  transform: translateX(-50%);
}

.smd-panel {
  width: 50%;
  flex-shrink: 0;
  min-width: 0;
}
</style>
