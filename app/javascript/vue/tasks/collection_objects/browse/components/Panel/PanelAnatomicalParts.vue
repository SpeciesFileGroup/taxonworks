<template>
  <PanelContainer title="Anatomical parts">
    <div>
      <VBtn
        v-if="anatomicalParts.length > 0"
        color="primary"
        class="margin-large-top"
        @click="() => (modalIsVisible = true)"
      >
        Visualize
      </VBtn>
    </div>
    <ListITems
      :list="anatomicalParts"
      label="generalized_name"
      :remove="false"
    />
  </PanelContainer>

  <VModal
    v-if="modalIsVisible"
    :container-style="{ width: '90vw' }"
    @close="() => (modalIsVisible = false)"
  >
    <template #header>
      <h3>Collection object anatomical parts</h3>
    </template>
    <template #body>
      <AnatomicalPartsGraph
        ref="graph"
        graph-width="89vw"
        graph-height="90vh"
        :show-node-quick-forms="false"
      />
    </template>
  </VModal>
</template>

<script setup>
import { computed, nextTick, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import ListITems from '@/components/displayList.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import AnatomicalPartsGraph from '@/tasks/anatomical_parts/anatomical_parts_graph/components/AnatomicalPartsGraph.vue'

const modalIsVisible = ref(false)
const graph = ref(null)

const store = useStore()
const anatomicalParts = computed(
  () => {
    const parts = store.getters[GetterNames.GetAnatomicalParts]
    return parts.map((p) => ({
      generalized_name: p.name ? p.name : p.uri_label
    }))
  }
)

watch(modalIsVisible, () => {
  if (modalIsVisible.value) {
    nextTick(() => {
      graph.value.createGraph({ collection_object_id: store.getters[GetterNames.GetCollectionObject].id })
    })
  }
})

</script>

<style scoped>
.flexless-button {
  flex: 0 1 auto;
  width: auto;
}
</style>