<template>
  <div
    v-if="item"
    class="smart-selector-item middle flex-separate gap-small"
  >
    <slot
      name="label"
      :item="item"
    >
      <span
        v-if="label"
        v-html="item[label]"
      />
      <span
        v-else
        v-html="item"
      />
    </slot>
    <div class="horizontal-left-content middle gap-small">
      <slot name="options-left" />
      <VBtn
        :color="unsetColor"
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
  },

  unsetColor: {
    type: String,
    default: 'primary'
  }
})
const emit = defineEmits(['unset'])
</script>
<style scoped>
.smart-selector-item {
  padding: var(--spacing-xxs) var(--spacing-xxs) var(--spacing-xxs)
    var(--spacing-xs);
  border: 1px solid var(--border-weak-color);
  border-radius: var(--border-radius-medium);
  background-color: var(--bg-muted);
}
</style>
