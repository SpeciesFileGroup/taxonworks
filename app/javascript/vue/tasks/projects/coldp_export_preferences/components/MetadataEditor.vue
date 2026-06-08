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
        <p class="small_type margin-small-top">
          The <code>issued</code>, <code>version</code>, and <code>platform</code> fields are automatically updated each time the export is generated.
        </p>
      </template>

      <template v-else-if="maintainMetadataInChecklistbank">
        <p class="feedback-warning padding-small">
          No ChecklistBank dataset ID is configured for this profile.
          Set one in the configuration panel to link to ChecklistBank metadata.
        </p>
      </template>

      <template v-else>
        <p class="small_type margin-small-bottom">
          The <code>issued</code>, <code>version</code>, and <code>platform</code> fields are automatically updated each time the export is generated.
        </p>

        <YamlEditor
          v-model="localYaml"
          :rows="20"
        />

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

const isFetching = ref(false)

async function fetchClbMetadata() {
  isFetching.value = true
  try {
    const { body } = await ColdpExportPreference.fetchClbMetadata(
      props.projectId,
      { checklistbank_dataset_id: props.checklistbankDatasetId }
    )
    if (body.metadata_yaml) {
      emit('update:metadata-yaml', body.metadata_yaml)
    }
  } catch {
    TW.workbench.alert.create('Failed to fetch metadata from ChecklistBank.', 'error')
  } finally {
    isFetching.value = false
  }
}

async function validateMetadata() {
  try {
    const { body } = await ColdpExportPreference.validateProfile(
      props.projectId,
      { metadata_yaml: props.metadataYaml }
    )
    const errors = body.errors || []
    if (errors.length > 0) {
      TW.workbench.alert.create(errors.join('; '), 'error')
      return false
    }
    TW.workbench.alert.create('YAML is valid.', 'notice')
    return true
  } catch {
    TW.workbench.alert.create('Validation request failed.', 'error')
    return false
  }
}

async function validateAndSave() {
  const isValid = await validateMetadata()
  if (isValid) {
    emit('save')
  }
}
</script>
