<template>
  <VBtn
    type="button"
    class="button normal-input button-delete"
    @click="handleClick"
  >
    Destroy all observations
  </VBtn>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { useStore } from 'vuex'
import { ref } from 'vue'
import { Observation } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters'
import ConfirmationModal from 'components/ConfirmationModal.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const store = useStore()
const confirmationModalRef = ref(null)

const handleClick = async () => {
  const ok = await confirmationModalRef.value.show({
    title: 'Destroy all observations',
    message: 'This will destroy all observations in this row. Are you sure you want to proceed? Type "DELETE" to proceed.',
    confirmationWord: 'DELETE',
    okButton: 'Delete all',
    cancelButton: 'Cancel',
    typeButton: 'delete'
  })

  if (ok) {
    await Observation.destroyColumn({ observation_matrix_column_id: store.getters[GetterNames.GetObservationColumnId] })
    window.location.reload()
  }
}
</script>
