<template>
  <div>
    <h3>Select observation matrix to open MRC or Image matrix</h3>
    <div>
      <VSpinner
        v-if="isLoading"
        legend="Loading"
      />
      <div>
        <div class="separate-bottom horizontal-left-content">
          <input
            v-model="filterType"
            type="text"
            placeholder="Filter matrix"
          />
          <default-pin
            section="ObservationMatrices"
            type="ObservationMatrix"
            @get-id="setMatrix"
          />
        </div>
        <div class="flex-separate">
          <div>
            <ul class="no_bullets">
              <template v-for="item in alreadyInMatrices">
                <li
                  :key="item.id"
                  v-if="
                    item.object_tag
                      .toLowerCase()
                      .includes(filterType.toLowerCase())
                  "
                >
                  <button
                    class="button normal-input button-default margin-small-bottom"
                    @click="loadMatrix(item)"
                    v-html="item.object_tag"
                  />
                </li>
              </template>
            </ul>
            <ul class="no_bullets">
              <template v-for="item in matrices">
                <li
                  :key="item.id"
                  v-if="
                    item.object_tag
                      .toLowerCase()
                      .includes(filterType.toLowerCase()) &&
                    !alreadyInMatrices.includes(item)
                  "
                >
                  <button
                    class="button normal-input button-submit margin-small-bottom"
                    @click="loadMatrix(item)"
                    v-html="item.object_tag"
                  />
                </li>
              </template>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeMount, ref, watch } from 'vue'
import VSpinner from '@/components/ui/VSpinner'
import DefaultPin from '@/components/ui/Button/ButtonPinned'
import {
  ObservationMatrix,
  ObservationMatrixRow,
  ObservationMatrixRowItem
} from '@/routes/endpoints'
import { OBSERVATION_MATRIX_ROW_SINGLE } from '@/constants/index'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const alreadyInMatrices = computed(() =>
  matrices.value.filter((item) =>
    rows.value.find((row) => item.id === row.observation_matrix_id)
  )
)

const alreadyInCurrentMatrix = computed(() =>
  rows.value.filter(
    (row) => selectedMatrix.value.id === row.observation_matrix_id
  )
)

const show = ref(false)
const matrices = ref([])
const selectedMatrix = ref()
const rows = ref([])
const filterType = ref('')
const isLoading = ref(false)

watch(alreadyInMatrices, (newVal) => emit('updateCount', newVal.length), {
  deep: true
})

onBeforeMount(() => {
  isLoading.value = true
  show.value = true
  ObservationMatrix.all({ per: 500 }).then((response) => {
    matrices.value = response.body.sort((a, b) => {
      const compareA = a.object_tag
      const compareB = b.object_tag
      if (compareA < compareB) {
        return -1
      } else if (compareA > compareB) {
        return 1
      } else {
        return 0
      }
    })
    isLoading.value = false
  })
  ObservationMatrixRow.where({
    observation_object_type: props.objectType,
    observation_object_id: props.objectId
  }).then((response) => {
    rows.value = response.body
  })
})

function loadMatrix(matrix) {
  selectedMatrix.value = matrix
  if (matrix.is_media_matrix) {
    openImageMatrix(matrix.id)
  } else {
    openMatrixRowCoder(matrix.id)
  }
}

function reset() {
  selectedMatrix.value = undefined
  rows.value = []
  show.value = false
}

async function createRow() {
  const data = {
    observation_matrix_id: selectedMatrix.value.id,
    observation_object_type: props.objectType,
    observation_object_id: props.objectId,
    type: OBSERVATION_MATRIX_ROW_SINGLE
  }

  await ObservationMatrixRowItem.create({
    observation_matrix_row_item: data
  })

  const rowList = await ObservationMatrixRow.where({
    observation_object_id: props.objectId,
    observation_object_type: props.objectType
  })

  rows.value = rowList.body

  return rowList
}

function setMatrix(id) {
  ObservationMatrix.find(id).then(({ body }) => {
    selectedMatrix.value = body
    loadMatrix(selectedMatrix.value)
  })
}

function getRowId(observationMatrixId) {
  return rows.value.find((m) => m.observation_matrix_id === observationMatrixId)
    .id
}

async function openMatrixRowCoder(observationMatrixId) {
  if (!alreadyInCurrentMatrix.value.length) {
    await createRow()
  }

  window.open(
    `${RouteNames.MatrixRowCoder}?observation_matrix_row_id=${getRowId(
      observationMatrixId
    )}`,
    '_blank'
  )
  emit('close')
}

async function openImageMatrix(observationMatrixId) {
  if (!alreadyInCurrentMatrix.value.length) {
    await createRow()
  }

  window.open(
    `${RouteNames.ImageMatrix}?observation_matrix_id=${
      selectedMatrix.value.id
    }&row_filter=${getRowId(observationMatrixId)}&edit=true`,
    '_blank'
  )
  emit('close')
}
</script>
