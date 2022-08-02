<template>
  <div class="flex-separate">
    <div class="horizontal-left-content">
      <span class="margin-medium-right">Matrix: <b><span v-html="observationMatrix.object_tag" /></b></span>
      <ul class="no_bullets context-menu">
        <li>
          <a :href="`/tasks/observation_matrices/new_matrix/${observationMatrix.id}`">
            Edit
          </a>
        </li>
        <li>
          <a :href="`/tasks/observation_matrices/view/${observationMatrix.id}`">
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
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters.js'

const store = useStore()
const observationMatrix = computed(() => store.getters[GetterNames.GetObservationMatrix] || {})
</script>
