<template>
  <VModal
    @close="$emit('close')"
    :container-style="{ width: '800px' }"
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
        class="full_width table-striped"
      >
        <thead>
          <tr>
            <th>Source</th>
            <th class="w-2" />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="source in sources"
            :key="source.id"
          >
            <td>
              <span
                v-html="
                  source.cached || source.object_tag || `Source #${source.id}`
                "
              />
            </td>
            <td>
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
  </VModal>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import useStore from '../store/store'
import VModal from '@/components/ui/Modal.vue'
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
