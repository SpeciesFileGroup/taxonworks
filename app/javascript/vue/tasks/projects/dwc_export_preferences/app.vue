<template>
  <VSpinner
    v-if="isLoading"
    full-screen
    :logo-size="{ width: '100px', height: '100px' }"
  />

  <h1 data-help="A publicly accessible complete api download can't be created until the eml preferences below have been saved and the 'Is Public' box has been checked and saved. The first time the public download is requested by api it will fail but the download will be triggered to build. Once the first build completes there will always be a download available (until no longer public or deleted).">
    Darwin core export settings for project downloads
  </h1>

  <h2>Public sharing</h2>
  <div class="margin-medium-left">
    <div>
      <label data-help="Make this project's darwin core archive, determined by the settings on this page, PUBLICLY accessible from the api">
        <input
          type="checkbox"
          v-model="isPublic"
        />
        Is Public
      </label>
    </div>

    <VBtn
      @click="setIsPublic"
      color="create"
      class="margin-medium-top"
    >
      Save "Is Public"
    </VBtn>
  </div>

  <h2>Extensions</h2>
  <div class="margin-medium-left">
    <template
      v-for="(v, k) in EXTENSIONS"
      :key="k"
    >
      <div>
        <label>
          <input
            type="checkbox"
            v-model="extensions"
            :value="k"
            name="extensions"
          >
            {{ v }}
          </input>
        </label>
      </div>
    </template>

    <VBtn
      @click="setExtensions"
      color="create"
      class="margin-medium-top"
    >
      Save extensions
    </VBtn>
  </div>

  <h2>EML</h2>
  <div class="margin-medium-left">
    <template v-if="datasetErrors?.length > 0">
      <fieldset
        class="padding-large-right"
        style="max-width: 600px"
      >
        <legend class="feedback-danger">Errors in dataset xml</legend>
        <ul
          v-for="msg in datasetErrors"
          :key="msg"
        >
          <li>{{ msg }}</li>
        </ul>
      </fieldset>
    </template>

    <template v-else-if="datasetErrors?.length == 0">
      <div class="feedback-success d-inline-block padding-xsmall">
        Dataset xml is valid
      </div>
    </template>

    <div>
      <p>
        Dataset ({{ autoFilledFields?.dataset?.join(', ')}} will be auto-set on DwCA
        creation):
      </p>
      <textarea
        v-model="dataset"
        rows="44"
        cols="80"
      />
    </div>

    <br>

    <template v-if="additionalMetadataErrors?.length > 0">
      <fieldset
        class="padding-large-right"
        style="max-width: 600px"
      >
        <legend class="feedback-danger">Errors in additional metadata xml</legend>
        <ul
          v-for="msg in additionalMetadataErrors"
          :key="msg"
        >
          <li>{{ msg }}</li>
        </ul>
      </fieldset>
    </template>
    <template v-else-if="additionalMetadataErrors?.length == 0">
      <div class="feedback-success d-inline-block padding-small">
        Additional metadata xml is valid
      </div>
    </template>

    <div>
      <p>
        Additional metadata ({{autoFilledFields?.additional_metadata?.join(', ') }}
        will be auto-set on DwCA creation):
      </p>
      <textarea
        v-model="additionalMetadata"
        rows="13"
        cols="80"
      />
    </div>

    <VBtn
      @click="validateAndSaveEML"
      color="create"
      class="margin-medium-top margin-large-bottom"
    >
      Validate and save EML
    </VBtn>
  </div>
</template>

<script setup>
import { getCurrentProjectId } from '@/helpers/project.js'
import { DwcExportPreference } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const EXTENSIONS = {
  resource_relationships: 'Resource relationships (biological associations)',
  media: 'Media'
}

const projectId = Number(getCurrentProjectId())
const isPublic = ref(false)
const dataset = ref('')
// null means not validated, array value means validated, possibly with 0 errors.
const datasetErrors = ref(null)
const additionalMetadata = ref('')
const additionalMetadataErrors = ref(null)
const autoFilledFields = ref({})
const extensions = ref([])
const isLoading = ref(false)

onBeforeMount(() => {
  isLoading.value = true
  DwcExportPreference.preferences(projectId)
    .then(({ body }) => {
      isPublic.value = body.is_public
      extensions.value = body.extensions
      dataset.value = body.eml_preferences.dataset
      additionalMetadata.value = body.eml_preferences.additional_metadata
      autoFilledFields.value = body.auto_filled
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
})

function setIsPublic() {
  isLoading.value = true
  DwcExportPreference.setIsPublic(projectId, { is_public: isPublic.value })
    .then(() => {
      TW.workbench.alert.create('Saved "Is Public".', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function setExtensions() {
  isLoading.value = true
  DwcExportPreference.setExtensions(projectId, { extensions: extensions.value })
    .then(() => {
      TW.workbench.alert.create('Saved extensions.', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function validateAndSaveEML() {
  const payload = {
    dataset: dataset.value,
    additional_metadata: additionalMetadata.value
  }
  isLoading.value = true
  DwcExportPreference.validateEML(payload)
    .then(({ body }) => {
      datasetErrors.value = body.dataset_errors
      additionalMetadataErrors.value = body.additional_metadata_errors
      if (datasetErrors.value.length == 0 &&
        additionalMetadataErrors.value.length == 0) {
          DwcExportPreference.saveEML(projectId, payload)
            .then(() => {
              TW.workbench.alert.create('Saved EML.', 'notice')
            })
            .catch(() => {})
        }
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}



</script>