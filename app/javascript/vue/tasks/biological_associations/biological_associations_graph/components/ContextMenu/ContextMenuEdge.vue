<template>
  <div
    v-for="edgeId in store.currentEdge"
    :key="edgeId"
    class="flex-separate middle gap-small graph-context-menu-list-item"
  >
    {{ store.edges[edgeId]?.label }}
    <div class="horizontal-right-content gap-xsmall">
      <VBtn
        color="primary"
        class="circle-button"
        @click="
          () => {
            store.reverseRelation(edgeId)
            emit('focusout')
          }
        "
      >
        <VIcon
          name="swap"
          x-small
        />
      </VBtn>
      <VBtn
        circle
        :color="store.edges[edgeId].id ? 'destroy' : 'primary'"
        @click="
          () => {
            removeEdge(edgeId)
          }
        "
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
    </div>
  </div>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { useGraphStore } from '../../store/useGraphStore.js'
import { ref } from 'vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const store = useGraphStore()
const emit = defineEmits(['focusout'])

const confirmationModalRef = ref()

async function removeEdge(edgeId) {
  const ok =
    !store.edges[edgeId].id ||
    (await confirmationModalRef.value.show({
      title: 'Destroy biological association',
      message:
        'This will delete the biological association. Are you sure you want to proceed?',
      okButton: 'Destroy',
      cancelButton: 'Cancel',
      typeButton: 'submit'
    }))

  if (ok) {
    store.removeEdge(edgeId)
    emit('focusout')
  }
}
</script>
