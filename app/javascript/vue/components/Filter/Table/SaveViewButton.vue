<template>
  <VBtn
    color="create"
    circle
    title="Save view to preferences"
    @click="onClick"
  >
    <VIcon
      name="floppyDisk"
      x-small
    />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const emit = defineEmits(['save'])

function onClick() {
  emit('save')
  if (typeof TW !== 'undefined' && TW.workbench?.alert) {
    TW.workbench.alert.create('View saved as your default.', 'notice')
  }
}
</script>
