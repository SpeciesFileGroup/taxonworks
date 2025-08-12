<template>
  <VToggle title="Broadcast">
    <VIcon
      name="broadcast"
      x-small
    />
  </VToggle>
</template>

<script setup>
import VToggle from '../VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineOptions({
  name: 'VBroadcast'
})
</script>
