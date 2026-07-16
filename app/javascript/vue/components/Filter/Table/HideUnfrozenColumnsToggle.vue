<template>
  <VToggle
    medium
    title="Hide/show non-frozen columns"
    @click="() => (hideUnfrozen = !hideUnfrozen)"
  >
    <component
      :is="hideUnfrozen ? IconEyeOff : IconEye"
      class="w-4 h-4"
    />
  </VToggle>
</template>

<script setup>
import VToggle from '@/components/ui/VToggle.vue'
import IconEye from '@/components/Icon/IconEye.vue'
import IconEyeOff from '@/components/Icon/IconEyeOff.vue'

const hideUnfrozen = defineModel({
  type: Boolean,
  default: false
})
</script>
