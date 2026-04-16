<template>
  <div
    v-if="item"
    class="middle flex-separate gap-small"
  >
    <p
      v-if="label"
      v-html="item[label]"
    />
    <p
      v-else
      v-html="item"
    />
    <div class="horizontal-left-content middle gap-small">
      <slot name="options-left" />
      <VBtn
        color="primary"
        circle
        @click="emit('unset')"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
      <slot name="options-right" />
    </div>
  </div>
</template>
<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

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
