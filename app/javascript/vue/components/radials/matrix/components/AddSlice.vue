<template>
  <div>
    <VSpinner
      v-if="isLoading"
      legend="Loading"
    />
    <div>
      <div class="separate-bottom horizontal-left-content">
        <input
          v-model="inputType"
          type="text"
          placeholder="Filter matrix"
        />
        <DefaultPin
          class="margin-small-left"
          section="ObservationMatrices"
          type="ObservationMatrix"
          @get-id="addToMatrix"
        />
      </div>
      <div class="flex-separate">
        <div>
          <div class="flex-wrap-column align-start gap-small">
            <template
              v-for="item in matrixList"
              :key="item.id"
            >
              <VBtn
                medium
                color="create"
                v-html="item.object_tag"
                @click="addToMatrix(item.id)"
              />
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import VSpinner from '@/components/spinner'
import DefaultPin from '@/components/getDefaultPin'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes'
import { ObservationMatrix } from '@/routes/endpoints'
import { sortArray } from '@/helpers/arrays.js'
import { ref, computed, onBeforeMount } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const isLoading = ref(false)
const isSaving = ref(false)
const inputType = ref('')
const observationMatrices = ref([])

const matrixList = computed(() =>
  observationMatrices.value.filter((item) =>
    item.object_tag.toLowerCase().includes(inputType.value.toLowerCase())
  )
)

function addToMatrix(matrixId) {
  const payload = {
    ...props.parameters,
    observation_matrix_id: matrixId
  }

  isSaving.value = true

  ObservationMatrix.addBatch(payload)
    .then(({ body }) => {
      window.open(
        `${RouteNames.NewObservationMatrix}/${body.observation_matrix_id}`,
        '_blank'
      )
      TW.workbench.alert.create(
        `${body.rows} rows and ${body.columns} columns were successfully created.`,
        'notice'
      )
    })
    .finally(() => {
      isSaving.value = false
    })
}

onBeforeMount(() => {
  isLoading.value = true
  ObservationMatrix.all({ per: 500 })
    .then(({ body }) => {
      observationMatrices.value = sortArray(body, 'object_tag')
    })
    .finally((_) => {
      isLoading.value = false
    })
})
</script>
