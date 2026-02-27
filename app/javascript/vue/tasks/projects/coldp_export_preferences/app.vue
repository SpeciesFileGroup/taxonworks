<template>
  <VSpinner
    v-if="isLoading"
    full-screen
    :logo-size="{ width: '100px', height: '100px' }"
  />

  <h1>ColDP export preferences</h1>

  <ProfileSelector
    :profiles="profiles"
    :selected-index="selectedProfileIndex"
    @select="selectedProfileIndex = $event"
    @add="addProfile"
    @delete="deleteProfile"
  />

  <DatasetCitation
    v-if="savedChecklistbankDatasetId"
    :project-id="projectId"
    :dataset-id="savedChecklistbankDatasetId"
  />

  <CompleteDownloadControl
    v-if="currentProfile"
    :is-public="currentProfile.is_public || false"
    :project-token="projectToken || ''"
    :max-age="currentProfile.max_age || null"
    :otu-id="currentProfile.otu_id"
  />

  <div
    v-if="currentProfile"
    class="two-column"
  >
    <div class="flex-col left-column">
      <ConfigurationPanel
        :profile="currentProfile"
        :project-token="projectToken"
        @update:profile="updateCurrentProfile"
        @save="saveCurrentProfile"
      />

      <ControlledVocabularyPanel
        :project-id="projectId"
        :otu-id="currentProfile.otu_id"
      />

    </div>

    <div class="flex-col right-column">
      <MetadataEditor
        :metadata-yaml="currentProfile.metadata_yaml || ''"
        :project-id="projectId"
        :checklistbank-dataset-id="savedChecklistbankDatasetId"
        :maintain-metadata-in-checklistbank="currentProfile.maintain_metadata_in_checklistbank || false"
        @update:metadata-yaml="(val) => updateCurrentProfile({ ...currentProfile, metadata_yaml: val })"
        @update:maintain-metadata-in-checklistbank="(val) => updateCurrentProfile({ ...currentProfile, maintain_metadata_in_checklistbank: val })"
        @save="saveCurrentProfile"
      />

      <DataQualityPanel
        :project-id="projectId"
        :otu-id="currentProfile.otu_id"
        :dataset-id="savedChecklistbankDatasetId"
      />

    </div>
  </div>

  <div
    v-else-if="!currentProfile"
    class="panel padding-large margin-large-top"
  >
    <p>No profiles configured. Click "+ Add" to create a ColDP export profile.</p>
  </div>
</template>

<script setup>
import { getCurrentProjectId } from '@/helpers/project.js'
import { ColdpExportPreference, Project } from '@/routes/endpoints'
import { onBeforeMount, ref, computed } from 'vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ProfileSelector from './components/ProfileSelector.vue'
import ConfigurationPanel from './components/ConfigurationPanel.vue'
import MetadataEditor from './components/MetadataEditor.vue'
import CompleteDownloadControl from './components/CompleteDownloadControl.vue'
import ControlledVocabularyPanel from './components/ControlledVocabularyPanel.vue'
import DataQualityPanel from './components/DataQualityPanel.vue'
import DatasetCitation from './components/DatasetCitation.vue'

const projectId = Number(getCurrentProjectId())
const isLoading = ref(false)
const profiles = ref([])
const selectedProfileIndex = ref(0)
const projectToken = ref(null)
const coldpSettings = ref({})

const currentProfile = computed(() =>
  profiles.value.length > 0 ? profiles.value[selectedProfileIndex.value] : null
)

// The dataset ID as last persisted on the server, so that
// child components don't fire API calls on every keystroke.
const savedChecklistbankDatasetId = computed(() => {
  const p = currentProfile.value
  if (!p || !p.otu_id) return null
  return savedDatasetIds.value[p.otu_id] ?? p.checklistbank_dataset_id
})

const savedDatasetIds = ref({})

onBeforeMount(() => {
  isLoading.value = true

  Project.apiAccessToken(projectId)
    .then(({ body }) => projectToken.value = body.api_access_token)
    .catch(() => {})

  ColdpExportPreference.preferences(projectId)
    .then(({ body }) => {
      profiles.value = body.profiles || []
      coldpSettings.value = body.coldp_settings || {}
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
})

function addProfile() {
  profiles.value.push({
    otu_id: null,
    checklistbank_dataset_id: null,
    is_public: false,
    default_user_id: null,
    max_age: 6.0,
    metadata_yaml: '',
    maintain_metadata_in_checklistbank: false,
    base_url: ''
  })
  selectedProfileIndex.value = profiles.value.length - 1
}

function updateCurrentProfile(updated) {
  profiles.value[selectedProfileIndex.value] = updated
}

function saveCurrentProfile() {
  const profile = currentProfile.value

  if (!profile.otu_id) {
    TW.workbench.alert.create('Root OTU is required', 'error')
    return
  }

  isLoading.value = true

  ColdpExportPreference.saveProfile(projectId, profile)
    .then(({ body }) => {
      profiles.value = body.profiles || []
      coldpSettings.value = body.coldp_settings || {}
      // Reselect the same profile by otu_id
      const idx = profiles.value.findIndex(p => p.otu_id === profile.otu_id)
      selectedProfileIndex.value = idx >= 0 ? idx : 0
      // Track the persisted dataset ID so CLB panels only render after save
      if (profile.otu_id) {
        savedDatasetIds.value[profile.otu_id] = profile.checklistbank_dataset_id
      }
      TW.workbench.alert.create('Profile saved.', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function deleteProfile() {
  const profile = currentProfile.value
  if (!profile) return

  if (!profile.otu_id) {
    // Unsaved profile, just remove locally
    profiles.value.splice(selectedProfileIndex.value, 1)
    selectedProfileIndex.value = Math.max(0, selectedProfileIndex.value - 1)
    return
  }

  if (!confirm('Delete this profile? This cannot be undone.')) return

  isLoading.value = true
  ColdpExportPreference.destroyProfile(projectId, { otu_id: profile.otu_id })
    .then(({ body }) => {
      profiles.value = body.profiles || []
      selectedProfileIndex.value = Math.max(0, selectedProfileIndex.value - 1)
      TW.workbench.alert.create('Profile deleted.', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

</script>

<style lang="scss" scoped>
.two-column {
  display: flex;
  gap: 2em;
  margin-top: 1em;
}

.left-column,
.right-column {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1em;
}

</style>
