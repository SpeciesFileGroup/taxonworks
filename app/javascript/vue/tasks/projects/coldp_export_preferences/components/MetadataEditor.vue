<template>
  <div class="panel padding-large">
    <h2>Metadata (YAML)</h2>
    <div class="margin-medium-left">
      <label class="margin-medium-bottom d-block">
        <input
          type="checkbox"
          :checked="maintainMetadataInChecklistbank"
          @change="$emit('update:maintain-metadata-in-checklistbank', $event.target.checked)"
        />
        Maintain metadata in ChecklistBank
      </label>

      <template v-if="maintainMetadataInChecklistbank && checklistbankDatasetId">
        <p>
          Metadata is maintained in ChecklistBank.
          <a
            :href="`https://www.checklistbank.org/dataset/${checklistbankDatasetId}/metadata`"
            target="_blank"
          >
            Edit metadata on ChecklistBank
          </a>
        </p>
      </template>

      <template v-else-if="maintainMetadataInChecklistbank">
        <p class="feedback-warning padding-small">
          No ChecklistBank dataset ID is configured for this profile.
          Set one in the configuration panel to link to ChecklistBank metadata.
        </p>
      </template>

      <template v-else>
        <YamlEditor
          v-model="localYaml"
          :rows="20"
        />

        <div
          v-if="fetchError"
          class="feedback-danger padding-small margin-small-top"
        >
          {{ fetchError }}
        </div>

        <div
          v-if="validationErrors.length > 0"
          class="feedback-danger padding-small margin-small-top"
        >
          <ul>
            <li
              v-for="(error, idx) in validationErrors"
              :key="idx"
            >{{ error }}</li>
          </ul>
        </div>

        <div
          v-else-if="validated"
          class="feedback-success d-inline-block padding-xsmall margin-small-top"
        >
          YAML is valid
        </div>

        <div class="margin-medium-top">
          <VBtn
            v-if="checklistbankDatasetId"
            :disabled="isFetching"
            @click="fetchClbMetadata"
            color="primary"
            class="margin-small-right"
          >
            {{ isFetching ? 'Fetching...' : 'Fetch from ChecklistBank' }}
          </VBtn>

          <VBtn
            @click="validateMetadata"
            color="primary"
            class="margin-small-right"
          >
            Validate
          </VBtn>

          <VBtn
            @click="validateAndSave"
            color="create"
          >
            Validate and save
          </VBtn>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import YamlEditor from './YamlEditor.vue'

const props = defineProps({
  metadataYaml: {
    type: String,
    default: ''
  },
  projectId: {
    type: Number,
    required: true
  },
  checklistbankDatasetId: {
    type: Number,
    default: null
  },
  maintainMetadataInChecklistbank: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'update:metadata-yaml',
  'update:maintain-metadata-in-checklistbank',
  'save'
])

const localYaml = computed({
  get: () => props.metadataYaml,
  set: (val) => emit('update:metadata-yaml', val)
})

const validationErrors = ref([])
const validated = ref(false)
const isFetching = ref(false)
const fetchError = ref(null)

async function fetchClbMetadata() {
  isFetching.value = true
  fetchError.value = null
  try {
    const { body } = await ColdpExportPreference.fetchClbMetadata(
      props.projectId,
      { checklistbank_dataset_id: props.checklistbankDatasetId }
    )
    if (body.metadata_yaml) {
      emit('update:metadata-yaml', body.metadata_yaml)
    }
  } catch {
    fetchError.value = 'Failed to fetch metadata from ChecklistBank'
  } finally {
    isFetching.value = false
  }
}

async function validateMetadata() {
  validated.value = false
  try {
    const { body } = await ColdpExportPreference.validateMetadata(
      props.projectId,
      { metadata_yaml: props.metadataYaml }
    )
    validationErrors.value = body.errors || []
    validated.value = true
  } catch {
    validationErrors.value = ['Validation request failed']
  }
}

async function validateAndSave() {
  await validateMetadata()
  if (validationErrors.value.length === 0) {
    emit('save')
  }
}
</script>
