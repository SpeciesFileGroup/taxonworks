<template>
  <ul class="graph-context-menu-list">
    <li>
      <div class="flex-separate middle gap-small">
        <span>{{ store.getNodes[store.currentNode]?.name }}</span>
        <VBtn
          circle
          :color="isCreated ? 'destroy' : 'primary'"
          @click="
            () => {
              removeNode(store.currentNode)
            }
          "
        >
          <VIcon
            x-small
            name="trash"
          />
        </VBtn>
      </div>
    </li>
    <li v-if="store.selectedNodes.length === 2">
      <div
        type="button"
        @click="() => (store.modal.edge = true)"
      >
        Create relation
      </div>
    </li>
  </ul>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'
import { computed, ref } from 'vue'
import { useGraphStore } from '../../store/useGraphStore'

const store = useGraphStore()
const emit = defineEmits(['focusout'])

const isCreated = computed(
  () => store.getCreatedAssociationsByNodeId(store.currentNode).length > 0
)

const confirmationModalRef = ref()

async function removeNode(node) {
  const ok =
    !isCreated.value ||
    (await confirmationModalRef.value.show({
      title: 'Destroy biological association',
      message:
        'This will delete biological associations connected to this node. Are you sure you want to proceed?',
      okButton: 'Destroy',
      cancelButton: 'Cancel',
      typeButton: 'delete'
    }))

  if (ok) {
    store.removeNode(node)
    emit('focusout')
  }
}
</script>
