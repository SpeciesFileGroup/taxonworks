<template>
  <div class="horizontal-left-content">
    <a
      v-if="matrixRow.previous_row && matrixRow.previous_row.row_object"
      class="margin-small-right"
      href="#"
      v-html="matrixRow.previous_row.row_object.object_tag"
      @click="emit('select', matrixRow.previous_row.id)"
    />
    <autocomplete
      :array-list="rowLabels"
      placeholder="Search..."
      param="label"
      label="label"
      clear-after
      delay="0"
      @select="emit('select', $event.id)"
    />
    <a
      v-if="matrixRow.next_row && matrixRow.next_row.row_object"
      class="margin-small-left"
      href="#"
      v-html="matrixRow.next_row.row_object.object_tag"
      @click="emit('select', matrixRow.next_row.id)"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ObservationMatrix } from 'routes/endpoints'
import Autocomplete from 'components/ui/Autocomplete.vue'

const props = defineProps({
  matrixRow: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['select'])

const rowLabels = ref([])

ObservationMatrix.rowLabels(props.matrixRow.observation_matrix.id).then(({ body }) => {
  rowLabels.value = body
})
</script>
