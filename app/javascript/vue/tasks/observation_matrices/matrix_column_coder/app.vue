<template>
  <div>
    <div class="flex-separate middle">
      <h1>Matrix column coder</h1>
      <ul class="context-menu">
        <li>
          <a href="/tasks/observation_matrices/observation_matrix_hub">Observation matrix hub</a>
        </li>
      </ul>
    </div>
    <MatrixColumnCoder
      v-if="columnId"
      :column-id="columnId"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import MatrixColumnCoder from './MatrixColumnCoder/MatrixColumnCoder.vue'

const columnId = ref(null)
const urlParams = new URLSearchParams(window.location.search)
const id = urlParams.get('observation_matrix_column_id')

if (/^\d+$/.test(id)) {
  columnId.value = Number(id)
}
</script>
