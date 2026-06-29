<template>
  <div
    v-if="item"
    class="middle flex-separate gap-small"
  >
    <span
      v-if="label"
      v-html="item[label]"
    />
    <span
      v-else
      v-html="item"
    />
    <div class="horizontal-left-content middle gap-small">
      <slot name="options-left" />
      <VBtn
        color="primary"
        icon
        variant="tonal"
        @click="emit('unset')"
      >
        <IconTrash class="w-4 h-4" />
      </VBtn>
      <slot name="options-right" />
    </div>
  </div>
</template>
<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

defineProps({
  item: {
    type: [String, Object],
    default: undefined
  },

  label: {
    type: [String, Boolean],
    default: 'object_tag'
  }
})
const emit = defineEmits(['unset'])
</script>
