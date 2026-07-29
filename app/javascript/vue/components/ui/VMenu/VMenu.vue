<template>
  <VPopover
    ref="popoverRef"
    :placement="placement"
    :width="width"
    :disabled="disabled"
  >
    <template #trigger="{ triggerAttributes }">
      <slot
        name="trigger"
        :trigger-attributes="triggerAttributes"
      >
        <VBtn
          v-bind="triggerAttributes"
          icon
          medium
          variant="tonal"
          color="primary"
          :title="title"
          :disabled="disabled"
        >
          <IconMenu class="w-4 h-4" />
        </VBtn>
      </slot>
    </template>
    <template #default="{ close }">
      <div
        class="tw-menu"
        role="menu"
        @click="close"
      >
        <slot :close="close" />
      </div>
    </template>
  </VPopover>
</template>

<script setup>
import { ref } from 'vue'
import VPopover from '@/components/ui/VPopover/VPopover.vue'
import { PLACEMENTS } from '@/components/ui/VPopover/constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconMenu from '@/components/Icon/IconMenu.vue'

defineOptions({ name: 'VMenu' })

defineProps({
  placement: {
    type: String,
    default: 'bottom-end',
    validator: (value) => PLACEMENTS.includes(value)
  },

  title: {
    type: String,
    default: 'Menu'
  },

  width: {
    type: String,
    default: undefined
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const popoverRef = ref(null)

defineExpose({
  open: () => popoverRef.value?.open(),
  close: () => popoverRef.value?.close()
})
</script>
