<template>
  <div class="flex-separate middle gap-small graph-context-menu-list-item">
    {{ edge.label }}
    <div class="horizontal-right-content gap-xsmall">
      <VBtn
        color="primary"
        class="circle-button"
        @click="
          () => {
            emit('reverse:edge', edgeId)
          }
        "
      >
        <VIcon
          name="swap"
          x-small
        />
      </VBtn>
      <VBtn
        circle
        :color="!!edge.id ? 'destroy' : 'primary'"
        @click="
          () => {
            emit('remove:edge', edgeId)
          }
        "
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

defineProps({
  edgeId: {
    type: String,
    required: true
  },

  edge: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['remove:edge', 'reverse:edge'])
</script>
