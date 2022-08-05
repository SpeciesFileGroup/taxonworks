<template>
  <ul class="context-menu no_bullets">
    <li>
      <component
        :is="previousColumnId
          ? 'a'
          : 'span'
        "
        :href="`/tasks/observation_matrices/matrix_column_coder/index?observation_matrix_column_id=${previousColumnId}`"
      >
        ‹ Previous
      </component>
    </li>
    <li>
      <component
        :is="nextColumnId
          ? 'a'
          : 'span'
        "
        :href="`/tasks/observation_matrices/matrix_column_coder/index?observation_matrix_column_id=${nextColumnId}`"
      >
        Next ›
      </component>
    </li>
  </ul>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters'
import { useStore } from 'vuex'
import { computed } from 'vue'

const store = useStore()
const previousColumnId = computed(() => store.getters[GetterNames.GetPreviousColumn].id)
const nextColumnId = computed(() => store.getters[GetterNames.GetNextColumn].id)

</script>
