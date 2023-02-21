<template>
  <div>
    <VModal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Select a biological relationship</h3>
      </template>
      <template #body>
        <SmartSelector
          model="biological_relationships"
          @selected="addRelation"
        />
      </template>
    </VModal>

    <VBtn
      color="primary"
      medium
      :disabled="store.selectedNodes.length !== 2"
      @click="() => (isModalVisible = true)"
    >
      Create relation
    </VBtn>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { useGraphStore } from '../store/useGraphStore'
import { ref } from 'vue'

const store = useGraphStore()

const isModalVisible = ref(false)

function addRelation(relationship) {
  const [source, target] = store.selectedNodes

  store.createEdge({
    source,
    target,
    relationship
  })

  isModalVisible.value = false
}
</script>
