<template>
  <div
    :key="group.id"
    class="margin-small-bottom"
  >
    <span>{{ group.name }}</span>
    <div class="flex-wrap-row gap-small">
      <VBtn
        v-for="item in group.list"
        :key="item.id"
        :color="color"
        medium
        @click="emit('select', item)"
      >
        {{ item.name }}
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

defineProps({
  group: {
    type: Object,
    required: true
  },

  color: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['select'])
</script>
