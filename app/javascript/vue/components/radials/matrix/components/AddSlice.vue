<template>
  <div>
    <VSpinner v-if="isSaving" />
    <VAutocomplete
      url="/observation_matrices/autocomplete"
      label="label_html"
      placeholder="Search an observation matrix"
      param="term"
      clear-after
      @get-item="(item) => (matrix = item)"
    />
    <SmartSelectorItem
      :item="matrix"
      label="label_html"
      @unset="matrix = undefined"
    />

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!matrix"
      @click="addToMatrix"
    >
      Add
    </VBtn>

    <div
      v-if="created"
      class="margin-medium-top"
    >
      <h3>Created</h3>
      <ul>
        <li>Rows: {{ created.rows }}</li>
        <li>Columns: {{ created.columns }}</li>
      </ul>
      <a
        :href="`${RouteNames.NewObservationMatrix}/${created.observation_matrix_id}`"
        >Edit: {{ created.observation_matrix_name }}</a
      >
    </div>
  </div>
</template>

<script setup>
import VAutocomplete from 'components/ui/Autocomplete.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VSpinner from 'components/spinner.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { RouteNames } from 'routes/routes'
import { ObservationMatrix } from 'routes/endpoints'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const matrix = ref()
const created = ref(undefined)
const isSaving = ref(false)

function addToMatrix() {
  const payload = {
    ...props.parameters,

    observation_matrix_id: matrix.value.id
  }

  isSaving.value = true

  ObservationMatrix.addBatch(payload)
    .then(({ body }) => {
      created.value = body
      TW.workbench.alert.create(
        `${body.rows} rows and ${body.columns} columns were successfully created.`,
        'notice'
      )
      created.value = body
    })
    .finally(() => {
      isSaving.value = false
    })
}
</script>
