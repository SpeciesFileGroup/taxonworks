<template>
  <VModal
    v-if="modalVisible"
    @close="() => { modalVisible = false }"
    :container-style="{
      width: '600px'
    }"
  >
    <template #header>
      <h3>Select an interactive key to send lead otus to</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        legend="Loading..."
      />
      <VBtn
        v-if="defaultInteractiveKey"
        color="primary"
        @click="() => {
          chosenMatrixId = store.root.observation_matrix_id
          emit('click')
          modalVisible = false
        }"
        class="margin-large-bottom"
      >
        Send to '{{ defaultInteractiveKey }}'
      </VBtn>
      <select
        class="full_width margin-medium-bottom"
        v-model="chosenMatrixId"
      >
        <option :value="null">Select an observation matrix</option>
        <option
          v-for="item in observationMatrices"
          :key="item.id"
          :value="item.id"
        >
          {{ item.name }}
        </option>
      </select>

      <VBtn
        :disabled="!chosenMatrixId"
        color="primary"
        @click="() => {
          emit('click')
          modalVisible = false
        }"
        class="margin-medium-top"
      >
        Send to selected interactive key
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner'
import VModal from '@/components/ui/Modal.vue'
import useStore from '../store/leadStore.js'
import { ObservationMatrix } from '@/routes/endpoints'
import { computed, onBeforeMount, ref } from 'vue'

const props = defineProps({
  childIndex: {
    type: Number,
    default: null
  }
})

const observationMatrices = ref([])
const selectValue = ref([])
const isLoading = ref(false)

const store = useStore()

const modalVisible = defineModel('visible', {
  type: Boolean,
  default: false
})

const chosenMatrixId = defineModel('chosenMatrixId', {
  type: Number,
  default: null
})

const emit = defineEmits(['click'])

const defaultInteractiveKey = computed(() => {
  return observationMatrices.value.filter((m) => m.id == store.root.observation_matrix_id)[0]?.name
})

onBeforeMount(() => {
  isLoading.value = true
  ObservationMatrix.where({ per: 500 }).then(({ body }) => {
    observationMatrices.value = body
    isLoading.value = false
  })
})
</script>