<template>
  <div>
    <VSpinner v-if="isSaving" />
    <div class="field label-above">
      <input
        type="text"
        class="full_width"
        placeholder="Type an observation matrix name... "
        v-model="matrixName"
      />
    </div>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!matrixName.length"
      @click="addToMatrix"
    >
      Create
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
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/spinner.vue'
import { RouteNames } from '@/routes/routes'
import { ObservationMatrix } from '@/routes/endpoints'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const matrixName = ref('')
const created = ref(undefined)
const isSaving = ref(false)

function addToMatrix() {
  const payload = {
    ...props.parameters,
    observation_matrix: {
      name: matrixName.value
    }
  }

  isSaving.value = true

  ObservationMatrix.createBatch(payload)
    .then(({ body }) => {
      created.value = body
      TW.workbench.alert.create(
        `${body.rows} rows and ${body.columns} columns were successfully created.`,
        'notice'
      )
      matrixName.value = ''
      created.value = body
    })
    .finally(() => {
      isSaving.value = false
    })
}
</script>
