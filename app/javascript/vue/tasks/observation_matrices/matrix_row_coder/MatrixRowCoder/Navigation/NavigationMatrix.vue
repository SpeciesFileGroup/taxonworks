<template>
  <div class="flex-separate">
    <div class="horizontal-left-content">
      <span class="margin-medium-right">Matrix: <b><span v-html="matrixRow.observation_matrix.object_tag" /></b></span>
      <ul class="no_bullets context-menu">
        <li>
          <a :href="`/tasks/observation_matrices/new_matrix/${matrixRow.observation_matrix.id}`">
            Edit
          </a>
        </li>
        <li>
          <a :href="`/tasks/observation_matrices/view/${matrixRow.observation_matrix.id}`">
            View
          </a>
        </li>
      </ul>
    </div>
    <ul class="context-menu">
      <li>
        <a href="/tasks/observation_matrices/observation_matrix_hub">Observation matrix hub</a>
      </li>
    </ul>
  </div>
</template>

<script setup>

const props = defineProps({
  matrixRow: {
    type: Object,
    required: true
  }
})
</script>
