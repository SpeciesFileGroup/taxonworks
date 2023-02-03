<template>
  <div class="horizontal-right-content">
    <ul class="context-menu no_bullets">
      <li>
        <component
          :is="previousRowId
            ? 'a'
            : 'span'
          "
          :href="`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${previousRowId}`"
        >
          ‹ Previous
        </component>
      </li>
      <li>
        <component
          :is="nextRowId
            ? 'a'
            : 'span'
          "
          :href="`/tasks/observation_matrices/row_coder/index?observation_matrix_row_id=${nextRowId}`"
        >
          Next ›
        </component>
      </li>
    </ul>
    <Autocomplete
      class="margin-medium-left"
      :array-list="rowLabels"
      placeholder="Search..."
      param="label"
      label="label"
      clear-after
      time="0"
      @select="emit('select', $event.id)"
    />
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import { ObservationMatrix } from 'routes/endpoints'
import Autocomplete from 'components/ui/Autocomplete.vue'

const emit = defineEmits('select')

const store = useStore()
const previousRowId = computed(() => store.getters[GetterNames.GetMatrixRow]?.previous_row?.id)
const nextRowId = computed(() => store.getters[GetterNames.GetMatrixRow]?.next_row?.id)
const observationMatrixId = computed(() => store.getters[GetterNames.GetMatrixRow]?.observation_matrix?.id)

const rowLabels = ref([])

watch(
  observationMatrixId,
  () => {
    ObservationMatrix.rowLabels(observationMatrixId.value).then(({ body }) => {
      rowLabels.value = body
    })
  }
)

</script>
