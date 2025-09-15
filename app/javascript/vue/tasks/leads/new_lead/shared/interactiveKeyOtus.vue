<template>
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
      Add otus
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

<script setup>
import VSpinner from '@/components/ui/VSpinner'
import getPagination from '@/helpers/getPagination'
import { ObservationMatrix } from '@/routes/endpoints'
import { ref, watch, onBeforeMount } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  existingOtus: {
    type: Array,
    required: true
  }
})

const matrixSelected = ref()
const isLoading = ref(false)
const pagination = ref()
const rows = ref([])
const observationMatrices = ref([])
const rowsSelected = ref([])

const emit = defineEmits(['selected'])

onBeforeMount(() => {
  isLoading.value = true
  ObservationMatrix.where({ per: 500 }).then(({ body }) => {
    observationMatrices.value = body
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
    rows.value = rows.value.concat(
      response.body.filter((item) => (item.observation_object_type == 'Otu'))
    )
    pagination.value = getPagination(response)
    isLoading.value = false
  })
}

function addRows() {
  emit('selected', {
    observationMatrixId: matrixSelected.value.id,
    otuIds: rowsSelected.value.map((item) => item.observation_object.id)
  })
}

function alreadyExist(item) {
  return props.existingOtus.find(
    (id) => item.observation_object.id === id
  )
}

function selectAll() {
  rowsSelected.value = rows.value.filter((item) => !alreadyExist(item))
}

function unselectAll() {
  rowsSelected.value = []
}
</script>
