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

// The handler reports whether the save worked, see useFilterView.
const emit = defineEmits(['save'])

function onClick() {
  emit('save')
}
</script>
