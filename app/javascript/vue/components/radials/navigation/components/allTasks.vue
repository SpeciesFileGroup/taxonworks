<template>
  <VModal>
    <template #header>
      <h3>All tasks</h3>
    </template>
    <template #body>
      <div>
        <a
          v-for="(task, key) in metadata.tasks"
          :key="key"
          :href="task.path"
          class="panel content separate-left separate-bottom"
        >
          {{ task.name }}
        </a>
      </div>
    </template>
  </VModal>
</template>
<script setup>
import VModal from 'components/ui/Modal.vue'

defineProps({
  metadata: {
    type: Object,
    required: true
  }
})
</script>
