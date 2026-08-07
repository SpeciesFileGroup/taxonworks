<template>
  <VModal
    @close="$emit('close')"
    :container-style="{ width: '800px' }"
  >
    <template #header>
      <h3>Select Source for Citation</h3>
    </template>
    <template #body>
      <div class="margin-medium-bottom">
        <SmartSelector
          model="sources"
          pin-section="Sources"
          pin-type="Source"
          label="cached"
          :shorten="100"
          v-model="selectedSource"
          @selected="onSelected"
        />
        <SmartSelectorItem
          v-if="selectedSource"
          :item="selectedSource"
          label="cached"
          @unset="() => { selectedSource = null }"
        />
        <div class="margin-small-top">
          <VBtn
            color="create"
            medium
            :disabled="!selectedSource"
            @click="emitSelected"
          >
            Cite
          </VBtn>
        </div>
      </div>

      <div class="horizontal-center-content margin-medium-top margin-medium-bottom">
        <strong>OR</strong>
      </div>

      <VSpinner
        v-if="isLoading"
        legend="Loading recent sources..."
      />
      <div v-else-if="sources.length === 0">
        <p>No recent sources found.</p>
      </div>
      <table
        v-else
        class="full_width table-striped margin-medium-top"
      >
        <thead>
          <tr>
            <th>Recently updated sources</th>
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
                Cite
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
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const emit = defineEmits(['close', 'select'])

const store = useStore()
const sources = ref([])
const isLoading = ref(false)
const selectedSource = ref(null)

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

function onSelected(source) {
  selectedSource.value = source
}

function emitSelected() {
  if (selectedSource.value) {
    emit('select', selectedSource.value.id)
  }
}

function selectSource(sourceId) {
  emit('select', sourceId)
}
</script>
