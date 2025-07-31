<template>
  <VModal>
    <template #header>
      <h3>All tasks</h3>
    </template>
    <template #body>
      <div>
        <span
          v-for="(url, task) in tasks"
          :key="task"
          :href="task"
          class="panel content separate-left separate-bottom cursor-pointer"
          @click="emit('select', url)"
        >
          {{ capitalize(humanize(task)) }}
        </span>
      </div>
    </template>
  </VModal>
</template>
<script setup>
import { capitalize, humanize } from '@/helpers'
import VModal from '@/components/ui/Modal.vue'

defineProps({
  tasks: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])
</script>
