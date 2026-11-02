<template>
  <VBtn
    class="composition-remove"
    small
    circle
    title="Remove"
    @click.stop="emit('remove')"
  >
    <VIcon
      name="close"
      xx-small
    />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const emit = defineEmits(['remove'])
</script>
