<template>
  <VBtn
    circle
    color="primary"
    title="Sort descriptors (global order)"
    :disabled="!ids.length"
    @click="openModal"
  >
    <VIcon
      name="numberSort"
      x-small
    />
  </VBtn>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '800px' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Sort descriptors</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        legend="Loading..."
      />
      <p>
        Changes the global order of the selected descriptors. Descriptors that
        are not selected keep their position.
      </p>
      <div
        v-if="observationMatrices.length"
        class="horizontal-left-content gap-small margin-medium-bottom"
      >
        <label for="sort-descriptors-matrix">Copy order from matrix</label>
        <select
          id="sort-descriptors-matrix"
          v-model="observationMatrixId"
        >
          <option :value="undefined">Select a matrix</option>
          <option
            v-for="matrix in observationMatrices"
            :key="matrix.id"
            :value="matrix.id"
          >
            {{ matrix.name }}
          </option>
        </select>
        <VBtn
          color="primary"
          medium
          :disabled="!observationMatrixId"
          @click="copyMatrixOrder"
        >
          Apply
        </VBtn>
      </div>
      <table class="table-striped full_width">
        <thead>
          <tr>
            <th>Name</th>
            <th>Observation matrices</th>
            <th />
          </tr>
        </thead>
        <VDraggable
          v-model="descriptors"
          tag="tbody"
          handle=".handle"
          item-key="id"
        >
          <template #item="{ element }">
            <tr>
              <td v-text="element.name" />
              <td
                v-text="
                  element.observation_matrices.map((m) => m.name).join(', ')
                "
              />
              <td>
                <VBtn
                  color="primary"
                  circle
                  class="handle"
                  title="Press and hold to drag descriptor"
                >
                  <VIcon
                    title="Press and hold to drag descriptor"
                    color="white"
                    name="scrollV"
                    small
                  />
                </VBtn>
              </td>
            </tr>
          </template>
        </VDraggable>
      </table>
    </template>
    <template #footer>
      <VBtn
        color="create"
        medium
        :disabled="isLoading || !descriptors.length"
        @click="saveOrder"
      >
        Save order
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import { Descriptor, ObservationMatrixColumn } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VDraggable from 'vuedraggable'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update'])

const isModalVisible = ref(false)
const isLoading = ref(false)
const descriptors = ref([])
const observationMatrixId = ref()

const observationMatrices = computed(() => {
  const matrices = {}

  descriptors.value.forEach((d) => {
    d.observation_matrices.forEach((m) => {
      matrices[m.id] = m
    })
  })

  return Object.values(matrices).sort((a, b) => a.name.localeCompare(b.name))
})

function openModal() {
  isModalVisible.value = true
  observationMatrixId.value = undefined
  loadDescriptors()
}

function loadDescriptors() {
  isLoading.value = true
  descriptors.value = []

  Descriptor.filter({
    descriptor_id: props.ids,
    per: props.ids.length,
    extend: ['observation_matrices']
  })
    .then(({ body }) => {
      descriptors.value = body.sort((a, b) => a.position - b.position)
    })
    .finally(() => {
      isLoading.value = false
    })
}

function copyMatrixOrder() {
  isLoading.value = true

  ObservationMatrixColumn.where({
    observation_matrix_id: observationMatrixId.value,
    per: 10000
  })
    .then(({ body }) => {
      const columnOrder = body.map((c) => c.descriptor_id)
      const inMatrix = descriptors.value
        .filter((d) => columnOrder.includes(d.id))
        .sort((a, b) => columnOrder.indexOf(a.id) - columnOrder.indexOf(b.id))

      descriptors.value = descriptors.value.map((d) =>
        columnOrder.includes(d.id) ? inMatrix.shift() : d
      )
    })
    .finally(() => {
      isLoading.value = false
    })
}

function saveOrder() {
  isLoading.value = true

  Descriptor.sort(descriptors.value.map((d) => d.id))
    .then(() => {
      TW.workbench.alert.create(
        'Descriptor order was successfully updated.',
        'notice'
      )
      isModalVisible.value = false
      emit('update')
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>
