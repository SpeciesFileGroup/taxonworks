<template>
  <div
    v-if="item"
    class="flex-separate middle gap-medium"
  >
    <span v-html="item.object_tag" />
    <div class="horizontal-left-content middle gap-small">
      <VBtn
        circle
        color="primary"
        @click="() => emit('remove', item)"
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
      <VLock v-model="lock" />
    </div>
  </div>
  <div v-else>{{ label }}</div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
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
