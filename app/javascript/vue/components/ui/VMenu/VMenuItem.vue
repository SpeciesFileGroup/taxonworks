<template>
  <component
    :is="tag"
    class="tw-menu__item"
    role="menuitem"
    :type="tag === 'button' ? 'button' : undefined"
    :href="isLink ? href : undefined"
    :disabled="tag === 'button' ? disabled : undefined"
    :aria-disabled="disabled ? 'true' : undefined"
  >
    <slot />
  </component>
</template>

<script setup>
import { computed } from 'vue'

defineOptions({ name: 'VMenuItem' })

const props = defineProps({
  href: {
    type: String,
    default: undefined
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const isLink = computed(() => !!props.href && !props.disabled)

const tag = computed(() => (isLink.value ? 'a' : 'button'))
</script>
