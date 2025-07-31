<template>
  <div
    color="create"
    class="flex-wrap-row gap-small margin-large-top"
  >
    <VBtn
      v-for="item in list"
      :key="item.id"
      :color="color"
      medium
      @click="() => emit('select', item)"
    >
      <span v-html="item.object_tag" />
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

defineProps({
  color: {
    type: String,
    default: 'primary'
  },

  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select'])
</script>
