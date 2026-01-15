<template>
  <Modal
    @close="$emit('close')"
    container-style="max-width: 600px;"
  >
    <template #header>
      <h3>Select Source for Citation</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isLoading"
        legend="Loading recent sources..."
      />
      <div v-else-if="sources.length === 0">
        <p>No recent sources found.</p>
      </div>
      <table
        v-else
        class="full_width"
      >
        <thead>
          <tr>
            <th>Source</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="source in sources"
            :key="source.id"
          >
            <td class="source-cell">
              <span v-html="source.cached || source.object_tag || `Source #${source.id}`" />
            </td>
            <td class="action-cell">
              <VBtn
                color="create"
                medium
                @click="selectSource(source.id)"
              >
                Select
              </VBtn>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </Modal>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import useStore from '../store/store'
import Modal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['close', 'select'])

const store = useStore()
const sources = ref([])
const isLoading = ref(false)

onMounted(async () => {
  isLoading.value = true
  try {
    sources.value = await store.loadRecentSources()
  } catch (error) {
    TW.workbench.alert.create('Error loading sources', 'error')
  } finally {
    isLoading.value = false
  }
})

function selectSource(sourceId) {
  emit('select', sourceId)
}
</script>

<style scoped>
table {
  border-collapse: collapse;
}

th,
td {
  padding: 8px;
  text-align: left;
}

th {
  background-color: #f5f5f5;
}

td {
  border-bottom: 1px solid #ddd;
}

.source-cell {
  width: 100%;
}

.action-cell {
  white-space: nowrap;
  text-align: right;
}
</style>
