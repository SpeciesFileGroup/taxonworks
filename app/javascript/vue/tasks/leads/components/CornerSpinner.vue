<template>
  <div id="spinner_target" />
  <template v-if="loading">
    <VSpinner
      :logo-size="{ width: '35px', height: '35px' }"
      target="#spinner_target"
      :show-legend="false"
      :legend-style="{ display: 'none' }"
      css-position="fixed"
    />
  </template>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  loading: {
    type: Boolean,
    required: true
  }
})
</script>

<style lang="scss" scoped>
#spinner_target {
  position: fixed;
  bottom: 0px;
  left: 0px;
  width: 35px;
  height: 35px;
}
</style>