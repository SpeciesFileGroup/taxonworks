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

      <div class="display-flex gap-small">
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

      <ButtonPinned
        type="ObservationMatrix"
        section="ObservationMatrices"
        @get-item="({ id }) => (chosenMatrixId = id)"
      />
      </div>

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
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner'
import VModal from '@/components/ui/Modal.vue'
import useStore from '../store/leadStore.js'
import { ObservationMatrix } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'

const props = defineProps({
  childIndex: {
    type: Number,
    default: null
  }
})

const observationMatrices = ref([])
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

onBeforeMount(() => {
  if (store.root.observation_matrix_id) {
    chosenMatrixId.value = store.root.observation_matrix_id
    emit('click')
    return
  }

  isLoading.value = true
  ObservationMatrix.where({ per: 500 })
    .then(({ body }) => {
      observationMatrices.value = body
    })
    .then(() => { isLoading.value = false })
})
</script>