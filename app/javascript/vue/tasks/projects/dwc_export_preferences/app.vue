<template>
  <VSpinner
    v-if="isLoading"
    full-screen
    :logo-size="{ width: '100px', height: '100px' }"
  />

  <h1 data-help="This page is used to configure and enable a publicly available link to a 'complete' (i.e. all records) Darwin Core Archive download of your project. It is independent of any DwCA exports you might create using the DwC Dashboard or DwC creation via Filters.
  A publicly accessible complete API download can't be created until the EML preferences below have been saved and the 'Is Public' box has been checked and saved. The first time the public download is requested by the API link it will fail but the download will be triggered to build. Once the first build completes there will always be a download available (until no longer public or deleted). Once your download is public you can click the 'Public download link' API link to trigger download creation/retrieval.">
    Darwin core export settings for project downloads
  </h1>

  <div class="content-wrapper">
    <Transition name="expand">
      <CompleteDownloadControl
        :is-public="lastSavedData.isPublic || false"
        :project-token="projectToken || ''"
        :max-age="maxAge || null"
      />
    </Transition>

    <div class="two-column">
    <div class="flex-col">
      <div class="panel padding-large margin-large-bottom padding-xsmall-top">
        <h2>Public sharing</h2>
        <div class="margin-medium-left">
          <div>
            <label data-help="Make this project's darwin core archive, determined by the settings on this page, PUBLICLY accessible from the 'Public download link' given on this page.">
              <input
                :disabled="isPublicIsDisabled"
                type="checkbox"
                v-model="isPublic"
              />
              Is Public
            </label>
          </div>

          <div
            v-if="isPublicIsDisabledByNoToken"
            class="feedback-warning padding-xsmall margin-medium-left is-public-disabled-warning"
          >
            A project token for this project must be set to make downloads public
          </div>
          <div
            v-if="isPublicIsDisabledByStub"
            class="feedback-warning padding-xsmall margin-medium-left is-public-disabled-warning"
          >
            Remove all EML 'STUB' text to enable save
          </div>
          <div
            v-if="isPublicIsDisabledByNoDefaultUser"
            class="feedback-warning padding-xsmall margin-medium-left is-public-disabled-warning"
          >
            A default create/save user for complete downloads must be set
          </div>

          <VBtn
            :disabled="isPublicIsDisabled"
            @click="setIsPublic"
            color="create"
            class="margin-medium-top"
          >
            Save "Is Public"
          </VBtn>
        </div>

        <h2 data-help="When GBIF, for example, requests that a download be created, we must have a TaxonWorks user listed as the creator of that download: this is that user.">
          Default complete download creator
        </h2>
        <div class="margin-medium-left">
          <div class="user-select">
            <Autocomplete
              url="/users/autocomplete"
              label="label_html"
              min="2"
              placeholder="Select a user"
              param="term"
              clear-after
              class="margin-large-bottom"
              @getItem="(user) => (defaultUser = user)"
            />

            <span v-html="defaultUser?.label_html" />
            <VBtn
              v-if="defaultUser"
              class="margin-small-left"
              circle
              color="primary"
              @click="() => (defaultUser = null)"
            >
              <VIcon
                name="undo"
                small
              />
            </VBtn>
          </div>

          <VBtn
            :disabled="!defaultUser"
            @click="setDefaultUser"
            color="create"
            class="margin-large-top"
          >
            Save default download creator
          </VBtn>
        </div>

        <h2>Download age after which an API call triggers creation of a new download</h2>
        <div class="margin-medium-left">
          <div>
            <label>
              <input
                type="text"
                v-model.number="maxAge"
                class="text-number-input margin-xsmall-top"
                data-help="If someone requests a complete download using the 'Public download link' on this page, and that download is older than Max Age, then the old download will be returned but a new one will be created to replace it. In other words Max Age determines when a download request triggers creation of a new complete download to replace the existing complete download. Max age is a decimal value."
              />
              Age in days
            </label>
          </div>
          <div class="help-text margin-small-top">
            Suggested: 6 days for GBIF usage (GBIF downloads once per week)
          </div>

          <VBtn
            @click="setMaxAge"
            color="create"
            class="margin-medium-top"
          >
            Save Max Age
          </VBtn>
        </div>
      </div>

      <div class="panel padding-large margin-large-bottom padding-xsmall-top full_height">
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

        <h2>Predicates</h2>
        <div class="margin-medium-left">
          <VBtn
            @click="setPredicatesAndInternalValues"
            color="create"
            class="margin-large-bottom"
          >
            Save predicates
          </VBtn>

          <PredicateFilter
            v-model:collecting-event-predicate-id="predicateParams.collecting_event_predicate_id"
            v-model:collection-object-predicate-id="predicateParams.collection_object_predicate_id"
            v-model:taxonworks-extension-methods="selectedExtensionMethods.taxonworks_extension_methods"
            class="predicate-filter"
          />
        </div>
      </div>
    </div>


    <div class="panel padding-large margin-large-bottom padding-xsmall-top">
      <h2>EML</h2>
      <div class="margin-medium-left">
        <EmlFileLoader
          @eml-loaded="handleEmlLoaded"
          class="margin-large-bottom"
        />

        <fieldset
          v-if="datasetErrors?.length > 0"
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

        <div
          v-else-if="datasetErrors?.length == 0"
          class="feedback-success d-inline-block padding-xsmall"
        >
          Dataset xml is valid
        </div>

        <div>
          <p>
            Dataset ({{ autoFilledFields?.dataset?.join(', ')}} will be auto-set on DwCA
            creation):
          </p>

          <template v-if="datasetHasStubText">
            <div class="feedback-warning d-inline-block padding-xsmall">
              Contains 'STUB' text
            </div>
            <br>
          </template>

          <XmlEditor
            v-model="dataset"
            :rows="44"
            match-tags
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

          <template v-if="additionalMetadataHasStubText">
            <div class="feedback-warning d-inline-block padding-xsmall">
              Contains 'STUB' text
            </div>
            <br>
          </template>

          <XmlEditor
            v-model="additionalMetadata"
            :rows="13"
            match-tags
          />
        </div>

        <VBtn
          @click="validateAndSaveEML"
          color="create"
          class="margin-medium-top margin-xlarge-bottom"
        >
          Validate and save EML
        </VBtn>
      </div>
    </div>
  </div>
  </div>
</template>

<script setup>
import { getCurrentProjectId } from '@/helpers/project.js'
import { DwcExportPreference } from '@/routes/endpoints'
import { computed, onBeforeMount, reactive, ref, toRaw } from 'vue'
import { Project, User } from '@/routes/endpoints'
import PredicateFilter from '@/components/Export/PredicateFilter.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import EmlFileLoader from './components/EmlFileLoader.vue'
import XmlEditor from './components/XmlEditor.vue'
import CompleteDownloadControl from './components/CompleteDownloadControl.vue'

const EXTENSIONS = {
  resource_relationships: 'Resource relationships (biological associations)',
  media: 'Media'
}

const projectId = Number(getCurrentProjectId())
const adminUser = ref(false) // Checked again on submission.
const maxAge = ref(null)
const isPublic = ref(false)
const dataset = ref('')
// null means not validated, array value means validated, possibly with 0 errors.
const datasetErrors = ref(null)
const additionalMetadata = ref('')
const additionalMetadataErrors = ref(null)
const autoFilledFields = ref({})
const extensions = ref([])
const predicateParams = reactive({
  collecting_event_predicate_id: [],
  collection_object_predicate_id: []
})
const selectedExtensionMethods = reactive({
  taxonworks_extension_methods: []
})
const projectToken = ref(null)
const lastSavedData = ref({})
const defaultUser = ref(null)
const isLoading = ref(false)

const datasetHasStubText = computed(() => (dataset.value.includes('STUB')))
const additionalMetadataHasStubText =
  computed(() => (additionalMetadata.value.includes('STUB')))
const emlHasStubText = computed(() => (
  datasetHasStubText.value || additionalMetadataHasStubText.value
))

const isPublicIsDisabledByStub = computed(() => (!isPublic.value && emlHasStubText.value))
const isPublicIsDisabledByNoToken = computed(() => !projectToken.value)
const isPublicIsDisabledByNoDefaultUser = computed(() => !lastSavedData.value?.defaultUserId)
const isPublicIsDisabled = computed(() => isPublicIsDisabledByStub.value || isPublicIsDisabledByNoToken.value || isPublicIsDisabledByNoDefaultUser.value)

onBeforeMount(() => {
  isLoading.value = true

  Project.apiAccessToken(projectId)
    .then(({ body }) => projectToken.value = body.api_access_token)
    .catch(() => {})

  DwcExportPreference.preferences(projectId)
    .then(({ body }) => {
      adminUser.value = body.user_is_admin || false
      defaultUser.value = !!body.default_user_id ? { id: body.default_user_id } : null
      maxAge.value = body.max_age
      isPublic.value = body.is_public || false
      extensions.value = body.extensions || []
      predicateParams.collecting_event_predicate_id =
        body.predicates_and_internal_values?.collecting_event_predicate_id || []
      predicateParams.collection_object_predicate_id =
        body.predicates_and_internal_values?.collection_object_predicate_id || []
      selectedExtensionMethods.taxonworks_extension_methods =
        body.predicates_and_internal_values?.taxonworks_extension_methods || []
      dataset.value = body.eml_preferences?.dataset
      additionalMetadata.value = body.eml_preferences?.additional_metadata
      autoFilledFields.value = body.auto_filled

      // Load email instead of saving it in prefs.
      if (body.default_user_id) {
        User.find(body.default_user_id, { extend: ['user_email_tag']})
          .then(({ body }) => {
            defaultUser.value = body
            setLastSaved()
          })
          .catch(() => {})
      }

      setLastSaved()
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
})

function setLastSaved() {
  lastSavedData.value = {
    defaultUserId: defaultUser.value?.id,
    maxAge: maxAge.value,
    isPublic: isPublic.value,
    extensions: extensions.value,
    predicateParams: JSON.parse(JSON.stringify(toRaw(predicateParams))),
    selectedExtensionMethods: JSON.parse(JSON.stringify(toRaw(selectedExtensionMethods))),
    dataset: dataset.value,
    additionalMetadata: additionalMetadata.value
  }
}

function noUnsavedChanges() {
  // Return true if data hasn't been loaded yet
  if (!lastSavedData.value || !lastSavedData.value.predicateParams || !lastSavedData.value.selectedExtensionMethods) {
    return true
  }
  return lastSavedData.value.defaultUserId == defaultUser.value?.id &&
    emptyEqual(lastSavedData.value.maxAge, maxAge.value) &&
    emptyEqual(lastSavedData.value.isPublic, isPublic.value) &&
    arrayEqual(lastSavedData.value.extensions, extensions.value) &&
    arrayEqual(lastSavedData.value.predicateParams.collecting_event_predicate_id, predicateParams.collecting_event_predicate_id) &&
    arrayEqual(lastSavedData.value.predicateParams.collection_object_predicate_id, predicateParams.collection_object_predicate_id) &&
    arrayEqual(lastSavedData.value.selectedExtensionMethods.taxonworks_extension_methods, selectedExtensionMethods.taxonworks_extension_methods) &&
    emptyEqual(lastSavedData.value.dataset, dataset.value) &&
    emptyEqual(lastSavedData.value.additionalMetadata, additionalMetadata.value)
}

function emptyEqual(v1, v2) {
  return v1 == v2 || (v1 == '' && v2 == null) || (v1 == null && v2 == '')
}

function arrayEqual(a1, a2) {
  if (!a1 || !a2) return a1 === a2
  return a1.sort().join() == a2.sort().join()
}

function setMaxAge() {
  isLoading.value = true
  DwcExportPreference.setMaxAge(projectId, { max_age: maxAge.value })
    .then(() => {
      setLastSaved()
      TW.workbench.alert.create('Saved maximum age.', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function setDefaultUser() {
  isLoading.value = true
  DwcExportPreference.setDefaultUser(projectId, { default_user_id: defaultUser.value.id })
    .then(() => {
      setLastSaved()
      TW.workbench.alert.create('Saved default user.', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}


function setIsPublic() {
  isLoading.value = true
  DwcExportPreference.setIsPublic(projectId, { is_public: isPublic.value })
    .then(() => {
      setLastSaved()
      TW.workbench.alert.create('Saved "Is Public".', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function setExtensions() {
  isLoading.value = true
  DwcExportPreference.setExtensions(projectId, { extensions: extensions.value })
    .then(() => {
      setLastSaved()
      TW.workbench.alert.create('Saved extensions.', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function setPredicatesAndInternalValues() {
  const payload = {
    predicates_and_internal_values: {
      collecting_event_predicate_id:
        predicateParams.collecting_event_predicate_id,
      collection_object_predicate_id:
        predicateParams.collection_object_predicate_id,
      taxonworks_extension_methods:
        selectedExtensionMethods.taxonworks_extension_methods
    }
  }
  isLoading.value = true
  DwcExportPreference.setPredicatesAndInternalValues(projectId, payload)
    .then(() => {
      setLastSaved()
       TW.workbench.alert.create('Saved predicates and internal values.', 'notice')
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function validateAndSaveEML() {
  if (emlHasStubText.value && isPublic.value) {
     TW.workbench.alert.create('Public EML can\'t be saved with "STUB" text', 'error')
     return
  }
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
              setLastSaved()
              TW.workbench.alert.create('Saved EML.', 'notice')
            })
            .catch(() => {})
      } else {
        let errors = ''
        if (datasetErrors.value.length > 0 && additionalMetadataErrors.value.length > 0) {
          errors = 'No EML was saved, errors in both dataset and additional metadata.'
        } else if (datasetErrors.value.length > 0) {
          errors = 'dataset has xml errors, was NOT saved; additional metadata WAS saved.'
        } else {
          errors = 'additional metadata has xml errors, was NOT saved; dataset WAS saved.'
        }
        TW.workbench.alert.create(errors, 'error')
      }
    })
    .catch(() => {})
    .finally(() => (isLoading.value = false))
}

function openLink(event) {
  if (noUnsavedChanges() || window.confirm('You have unsaved changes, are you sure you want to continue?')) {
    window.location.href = event.currentTarget.href
  }
}

function handleEmlLoaded(emlData) {
  dataset.value = emlData.dataset
  additionalMetadata.value = emlData.additionalMetadata

  datasetErrors.value = null
  additionalMetadataErrors.value = null

  TW.workbench.alert.create('EML file loaded. Remember to validate and save.', 'notice')
}

</script>

<style lang="scss" >
.predicate-filter {
  width: 700px;
}

.is-public-disabled-warning {
  vertical-align: bottom;
  width: fit-content;
  margin-top: 0.5em;
  margin-bottom: 0.5em;
}

#max-age {
  position: absolute;
  top: 10em;
  right: 2em;
}

.text-number-input {
  width: 5em;
  margin-right: 0.5em;
}

.content-wrapper {
  display: inline-block;
}

.two-column {
  display: flex;
  gap: 3em;
}

.user-select {
  width: 400px;
}

.expand-enter-active,
.expand-leave-active {
  transition: all 0.3s ease;
  overflow: hidden;
}

.expand-enter-from,
.expand-leave-to {
  opacity: 0;
  max-height: 0;
  margin-bottom: 0;
}

.expand-enter-to,
.expand-leave-from {
  opacity: 1;
  max-height: 500px;
  margin-bottom: 2em;
}
</style>
