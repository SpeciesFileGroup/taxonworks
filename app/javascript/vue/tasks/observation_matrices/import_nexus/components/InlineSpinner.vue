<template>
  <div
    class="inline_spinner"
  >
    <VSpinner
      :show-legend="false"
      :logo-size="{ width: '20px', height: '20px' }"
      :legend-style="{ display: 'none' }"
    />
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'
</script>

<style lang="scss" scoped>
.inline_spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  position: relative;
  top: 8px;
}
</style>