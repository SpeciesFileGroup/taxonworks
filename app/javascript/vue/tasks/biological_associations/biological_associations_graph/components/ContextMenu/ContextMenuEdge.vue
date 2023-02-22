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
            store.removeEdge(edgeId)
            showEdgeMenu = false
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
  </div>
</template>

<script setup>
import { useGraphStore } from '../../store/useGraphStore.js'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const store = useGraphStore()
const emit = defineEmits(['focusout'])
</script>
