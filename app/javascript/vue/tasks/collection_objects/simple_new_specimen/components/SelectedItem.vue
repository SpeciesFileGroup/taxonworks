<template>
  <div class="flex-separate middle">
    <input
      class="full_width"
      type="text"
      :value="item[label]"
      disabled
    >
    <VBtn
      class="margin-small-left"
      color="primary"
      circle
      @click="emit('unset')"
    >
      <VIcon
        x-small
        name="trash"
      />
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

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
