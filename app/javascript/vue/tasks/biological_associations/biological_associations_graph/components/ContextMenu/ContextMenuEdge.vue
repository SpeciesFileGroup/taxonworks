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
            emit('reverse:edge', edgeId)
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
import ConfirmationModal from 'components/ConfirmationModal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const emit = defineEmits(['remove:edge', 'reverse:edge'])

const store = useGraphStore()
</script>
