<template>
  <ul class="graph-context-menu-list">
    <li>
      <div class="flex-separate middle gap-small">
        <span>{{ store.getNodes[store.currentNode]?.name }}</span>
        <VBtn
          circle
          :color="
            store.getCreatedAssociationsByNodeId(store.currentNode).length
              ? 'create'
              : 'delete'
          "
          @click="
            () => {
              store.removeNode(store.currentNode)
              emit('focusout')
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
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { useGraphStore } from '../../store/useGraphStore'

const store = useGraphStore()
const emit = defineEmits(['focusout'])
</script>
