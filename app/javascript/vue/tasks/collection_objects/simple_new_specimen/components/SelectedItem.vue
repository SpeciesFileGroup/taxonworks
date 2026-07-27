<template>
  <div class="flex-separate middle">
    <input
      class="full_width"
      type="text"
      :value="item[label]"
      disabled
    />
    <VBtn
      class="margin-small-left"
      color="primary"
      icon
      variant="tonal"
      @click="emit('unset')"
    >
      <IconTrash class="w-4 h-4" />
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

defineProps({
  item: {
    type: Object,
    required: true
  },

  label: {
    type: String,
    default: 'label'
  }
})

const emit = defineEmits(['unset'])
</script>
