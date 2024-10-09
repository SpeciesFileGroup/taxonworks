<template>
  <VModal
    :container-style="{
      width: '500px',
      'overflow-y': 'scroll',
      'max-height': '60vh'
    }"
    @close="closeModal"
  >
    <template #header>
      <h3>Copy rows from matrix</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        legend="Loading..."
      />
      <select
        class="full_width margin-medium-bottom"
        v-model="matrixSelected"
      >
        <option :value="undefined">Select a observation matrix</option>
        <option
          v-for="item in observationMatrices"
          :key="item.id"
          :value="item"
        >
          {{ item.name }}
        </option>
      </select>
      <div
        v-if="matrixSelected"
        class="flex-separate margin-small-bottom"
      >
        <VBtn
          color="create"
          :disabled="!rowsSelected.length"
          @click="addRows"
        >
          Add rows
        </VBtn>
        <div
          class="horizontal-right-content middle gap-small"
          v-if="matrixSelected"
        >
          <VBtn
            color="primary"
            @click="selectAll"
          >
            Select all
          </VBtn>
          <VBtn
            color="primary"
            @click="unselectAll"
          >
            Unselect all
          </VBtn>
        </div>
      </div>
      <ul class="no_bullets">
        <li
          v-for="item in rows"
          :key="item.observation_object.id"
        >
          <label>
            <input
              type="checkbox"
              :value="item"
              v-model="rowsSelected"
              :disabled="alreadyExist(item)"
            />
            <span
              class="disabled"
              v-if="alreadyExist(item)"
            >
              <span v-html="item.observation_object.object_tag" /> ({{
                item.observation_object.base_class
              }}) <span>(Already added)</span></span
            >
            <span v-else>
              <span v-html="item.observation_object.object_tag" /> ({{
                item.observation_object.base_class
              }})
            </span>
          </label>
        </li>
      </ul>
    </template>
    <template #footer>
      <div class="flex-separate middle gap-small">
        <VBtn
          color="create"
          :disabled="!rowsSelected.length"
          @click="addRows"
        >
          Add rows
        </VBtn>
        <div
          class="horizontal-right-content middle gap-small"
          v-if="matrixSelected"
        >
          <VBtn
            color="primary"
            @click="selectAll"
          >
            Select all
          </VBtn>
          <VBtn
            color="primary"
            @click="unselectAll"
          >
            Unselect all
          </VBtn>
        </div>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import VSpinner from '@/components/ui/VSpinner'
import getPagination from '@/helpers/getPagination'

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { ObservationMatrix, ObservationMatrixRowItem } from '@/routes/endpoints'
import { computed, ref, watch, onBeforeMount } from 'vue'
import { useStore } from 'vuex'
import VBtn from '@/components/ui/VBtn/index.vue'
import ObservationTypes from '../../const/types.js'

const props = defineProps({
  matrixId: {
    type: [String, Number],
    required: true
  }
})

const emit = defineEmits('close')

const store = useStore()

const matrixSelected = ref()
const isLoading = ref(false)
const pagination = ref()
const rows = ref([])
const existingRows = computed(() => store.getters[GetterNames.GetMatrixRows])
const observationMatrices = ref([])
const rowsSelected = ref([])

onBeforeMount(() => {
  isLoading.value = true
  ObservationMatrix.where({ per: 500 }).then(({ body }) => {
    observationMatrices.value = body.filter(
      (item) => props.matrixId !== item.id
    )
    isLoading.value = false
  })
})

watch(matrixSelected, (newVal) => {
  if (newVal) {
    loadRows()
  } else {
    rows.value = []
  }
})

function loadRows(page = undefined) {
  isLoading.value = true

  ObservationMatrix.rows(matrixSelected.value.id, {
    per: 500,
    page: page,
    extend: ['observation_object']
  }).then((response) => {
    rows.value = rows.value.concat(response.body)
    pagination.value = getPagination(response)
    isLoading.value = false
  })
}

function addRows() {
  const index = existingRows.value.length
  const data = rowsSelected.value.map((item) => ({
    observation_matrix_id: props.matrixId,
    observation_object_id: item.observation_object.id,
    observation_object_type: item.observation_object.base_class,
    position: item.position + index,
    type: ObservationTypes.Row[item.observation_object.base_class]
  }))

  data.sort((a, b) => a - b)

  const promises = data.map((row) =>
    ObservationMatrixRowItem.create({ observation_matrix_row_item: row })
  )

  Promise.all(promises).then(() => {
    store.dispatch(ActionNames.GetMatrixObservationRows)
    rowsSelected.value = []
    TW.workbench.alert.create(
      'Rows was successfully added to matrix.',
      'notice'
    )
    closeModal()
  })
}

function alreadyExist(item) {
  return existingRows.value.find(
    (row) => item.observation_object.id === row.observation_object.id
  )
}

function closeModal() {
  emit('close')
}

function selectAll() {
  rowsSelected.value = rows.value.filter((item) => !alreadyExist(item))
}

function unselectAll() {
  rowsSelected.value = []
}
</script>
