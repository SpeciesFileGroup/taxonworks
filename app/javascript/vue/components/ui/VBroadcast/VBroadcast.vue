<template>
  <VToggle title="Broadcast: Synchronize data across tabs/windows">
    <VIcon
      title="Broadcast: Synchronize data across tabs/windows"
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
