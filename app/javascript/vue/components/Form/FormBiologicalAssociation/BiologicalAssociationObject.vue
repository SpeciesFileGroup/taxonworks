<template>
  <div
    v-if="item"
    class="flex-separate middle gap-medium"
  >
    <span v-html="item.object_tag" />
    <div class="horizontal-left-content middle gap-small">
      <VBtn
        icon
        variant="tonal"
        color="primary"
        @click="() => emit('remove', item)"
      >
        <IconTrash class="w-4 h-4" />
      </VBtn>
      <VLock v-model="lock" />
    </div>
  </div>
  <div v-else>{{ label }}</div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import VLock from '@/components/ui/VLock/index.vue'

defineProps({
  item: {
    type: Object,
    default: null
  },
  label: {
    type: String,
    default: 'Choose'
  }
})

const lock = defineModel('lock', {
  type: Boolean,
  default: false
})

const emit = defineEmits(['remove'])
</script>
