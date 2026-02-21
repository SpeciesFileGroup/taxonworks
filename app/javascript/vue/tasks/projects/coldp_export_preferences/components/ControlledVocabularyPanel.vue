<template>
  <div class="panel padding-large">
    <h2>Controlled Vocabulary</h2>
    <div class="margin-medium-left">
      <VSpinner v-if="isLoading" />

      <template v-else-if="status.length > 0">
        <table class="vue-table cv-table">
          <thead>
            <tr>
              <th>Term</th>
              <th>Definition</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in status"
              :key="item.key"
            >
              <td>{{ item.key }}</td>
              <td>
                <a
                  v-if="vocabUrl(item.key)"
                  :href="vocabUrl(item.key)"
                  target="_blank"
                >{{ vocabLabel(item.key) }} &#x2197;</a>
                <span
                  v-if="vocabNote(item.key)"
                  :class="{ 'margin-small-left': vocabUrl(item.key) }"
                  class="cv-note"
                >{{ vocabNote(item.key) }}</span>
              </td>
              <td>
                <span
                  v-if="item.exists"
                  class="cv-installed-badge"
                >
                  Installed
                </span>
                <span
                  v-else
                  class="feedback-warning padding-xsmall"
                >
                  missing
                </span>
              </td>
              <td>
                <VBtn
                  v-if="!item.exists"
                  color="create"
                  x-small
                  :disabled="creatingKeys.has(item.key)"
                  @click="createOne(item.key)"
                >
                  Create
                </VBtn>
              </td>
            </tr>
          </tbody>
        </table>

        <div class="margin-medium-top cv-actions">
          <VBtn
            v-if="hasMissing"
            color="create"
            :disabled="isCreating"
            @click="createMissing"
          >
            Create all missing
          </VBtn>

          <VBtn
            color="primary"
            @click="loadStatus"
          >
            Refresh
          </VBtn>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted, watch } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

// Maps IRI_MAP keys to their CLB vocab API endpoint and a human label.
// Terms without a vocab endpoint get null.
const VOCAB_DEFINITIONS = {
  extinct: { note: 'Boolean (1 or 0)' },
  temporal_range_end: { url: 'https://api.checklistbank.org/vocab/geotime', label: 'Geotime', note: 'Constrained vocabulary' },
  temporal_range_start: { url: 'https://api.checklistbank.org/vocab/geotime', label: 'Geotime', note: 'Constrained vocabulary' },
  lifezone: { url: 'https://api.checklistbank.org/vocab/environment', label: 'Environment', note: 'Constrained: Brackish, Freshwater, Marine, Terrestrial' },
  remarks: { note: 'Free text' },
  namePhrase: { note: 'Free text' },
  link: { note: 'URL' }
}

const props = defineProps({
  projectId: {
    type: Number,
    required: true
  },
  otuId: {
    type: Number,
    default: null
  }
})

const isLoading = ref(false)
const isCreating = ref(false)
const creatingKeys = reactive(new Set())
const status = ref([])

const hasMissing = computed(() => status.value.some(s => !s.exists))

onMounted(loadStatus)
watch(() => props.otuId, loadStatus)

function vocabUrl(key) {
  return VOCAB_DEFINITIONS[key]?.url || null
}

function vocabLabel(key) {
  return VOCAB_DEFINITIONS[key]?.label || key
}

function vocabNote(key) {
  return VOCAB_DEFINITIONS[key]?.note || null
}

async function loadStatus() {
  isLoading.value = true
  try {
    const { body } = await ColdpExportPreference.controlledVocabularyStatus(props.projectId)
    status.value = body
  } catch {
    status.value = []
  } finally {
    isLoading.value = false
  }
}

async function createOne(key) {
  creatingKeys.add(key)
  try {
    await ColdpExportPreference.createPredicate(props.projectId, { key })
    TW.workbench.alert.create(`Created predicate for ${key}.`, 'notice')
    await loadStatus()
  } catch {
    TW.workbench.alert.create(`Failed to create predicate for ${key}`, 'error')
  } finally {
    creatingKeys.delete(key)
  }
}

async function createMissing() {
  isCreating.value = true
  try {
    const { body } = await ColdpExportPreference.createMissingPredicates(props.projectId)
    TW.workbench.alert.create(`Created ${body.created.length} predicate(s).`, 'notice')
    await loadStatus()
  } catch {
    TW.workbench.alert.create('Failed to create predicates', 'error')
  } finally {
    isCreating.value = false
  }
}
</script>

<style lang="scss" scoped>
.cv-table {
  width: 100%;

  th, td {
    padding: 0.4em 0.6em;
  }
}

.cv-installed-badge {
  display: inline-block;
  padding: 0.2em 0.6em;
  border-radius: 0.25em;
  font-size: 0.85em;
  font-weight: 500;
  background-color: #43a047;
  color: white;
}

.cv-note {
  color: #888;
  font-size: 0.9em;
}

.cv-actions {
  display: flex;
  align-items: center;
  gap: 0.75em;
}
</style>
