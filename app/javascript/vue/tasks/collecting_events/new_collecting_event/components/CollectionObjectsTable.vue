<template>
  <div>
    <div>
      <spinner-component
        v-if="isLoading"
        legend="Loading"
        spinner-position="left"
        :legend-style="{
          fontSize: '14px'
        }"
        :logo-size="{
          width: '14px',
          height: '14px',
          marginRight: '4px'
        }"
      />
      <button
        type="button"
        class="button normal-input button-default"
        :disabled="!ceId"
        @click="showModal = true"
      >
        Add/Current ({{ list.length }})
      </button>
    </div>
    <modal-component
      v-if="showModal"
      @close="showModal = false"
      transparent
      :container-style="{
        width: '100%',
        maxWidth: '90vw',
        height: '90vh',
        overflowX: 'auto'
      }"
    >
      <template #header>
        <h3>Create collection objects</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start">
          <spinner-component
            v-if="isLoading || isSaving"
            :legend="
              isSaving
                ? `Creating ${currentIndex} of ${count} collection object(s)...`
                : 'Loading...'
            "
          />
          <div class="margin-medium-right max-w-md full_width">
            <div class="panel content margin-medium-bottom">
              <h3>Number to create</h3>
              <div class="flex-separate align-end">
                <div class="field label-above">
                  <input
                    min="1"
                    type="number"
                    max="100"
                    v-model.number="count"
                  />
                </div>
                <div class="field">
                  <button
                    class="button normal-input button-submit"
                    type="button"
                    @click="handleClick"
                  >
                    Create
                  </button>
                </div>
              </div>
            </div>
            <label-component
              class="margin-medium-bottom panel content"
              v-model="labelType"
            />
            <identifiers-component
              class="margin-medium-bottom panel content"
              title="Catalog number"
              v-model="catalogNumber"
              :count="count"
            />
            <identifiers-component
              class="margin-medium-bottom panel content"
              title="Record number"
              v-model="recordNumber"
              :count="count"
            />
            <preparation-types
              class="margin-medium-bottom panel content"
              v-model="preparationType"
            />
            <repository-component
              class="margin-medium-bottom panel content"
              v-model="repositoryId"
            />
            <biocuration-component
              class="margin-medium-bottom panel content"
              v-model="biocurations"
            />
            <determiner-component
              class="margin-medium-bottom panel content"
              v-model="determinations"
            />
            <tag-component
              class="margin-medium-bottom panel content"
              v-model="tagList"
            />
          </div>
          <div class="panel content flex-grow-2">
            <template v-if="noCreated.length">
              <h3>Creation errors ({{ noCreated.length }})</h3>
              <table class="full_width margin-medium-bottom">
                <thead>
                  <tr>
                    <th>Identifier</th>
                    <th>Error</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="(item, index) in noCreated"
                    :key="index"
                    class="contextMenuCells feedback feedback-warning"
                  >
                    <td>{{ item.label }}</td>
                    <td>
                      {{
                        Object.keys(item.error)
                          .map((k) => item.error[k])
                          .join(', ')
                      }}
                    </td>
                  </tr>
                </tbody>
              </table>
            </template>
            <span
              >{{ list.length }} object(s) are already associated with this
              collecting event</span
            >
            <h3>Existing</h3>
            <table class="full_width table-striped">
              <thead>
                <tr>
                  <th>ID</th>
                  <th class="half_width">Identifier</th>
                  <th class="half_width">Determination</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="item in list"
                  :key="item.id"
                  class="contextMenuCells"
                >
                  <td>{{ item.id }}</td>
                  <td
                    v-html="
                      item.identifiers.map((item) => item.cached).join('<br>')
                    "
                  />
                  <td
                    v-html="
                      item.taxon_determinations
                        .map((t) => t.object_tag)
                        .join('<br>')
                    "
                  />
                  <td>
                    <div
                      v-if="item.global_id"
                      class="horizontal-left-content gap-small"
                    >
                      <radial-annotator :global-id="item.global_id" />
                      <radial-navigation :global-id="item.global_id" />
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import {
  COLLECTION_OBJECT,
  IDENTIFIER_LOCAL_CATALOG_NUMBER,
  IDENTIFIER_LOCAL_RECORD_NUMBER
} from '@/constants/index.js'
import BiocurationComponent from './Biocuration'
import PreparationTypes from './PreparationTypes'
import ModalComponent from '@/components/ui/Modal'
import SpinnerComponent from '@/components/ui/VSpinner'
import IdentifiersComponent from './Identifiers'
import DeterminerComponent from './Determiner'
import RepositoryComponent from './Repository'
import LabelComponent from './Label'
import TagComponent from './Tags'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigation from '@/components/radials/navigation/radial'
import {
  BiocurationClassification,
  CollectionObject,
  TaxonDetermination
} from '@/routes/endpoints'
import { ref, watch } from 'vue'

const extend = ['taxon_determinations', 'identifiers']

const props = defineProps({
  ceId: {
    type: [Number, String],
    default: undefined
  }
})

const biocurations = ref([])
const showModal = ref(false)
const list = ref([])
const currentIndex = ref(0)
const isLoading = ref(false)
const catalogNumber = ref({
  start: undefined,
  namespace: undefined
})
const recordNumber = ref({
  start: undefined,
  namespace: undefined
})
const determinations = ref([])
const isSaving = ref(false)
const noCreated = ref([])
const preparationType = ref()
const repositoryId = ref()
const labelType = ref()
const tagList = ref([])
const count = ref(1)

watch(
  () => props.ceId,
  (newVal) => {
    noCreated.value = []
    if (newVal) {
      loadTable()
    } else {
      list.value = []
    }
  }
)

function makeIdentifierPayload({ identifier, namespace }, type) {
  const payload = {
    identifier: identifier,
    namespace_id: namespace.id,
    type
  }

  if (labelType.value) {
    Object.assign(payload, {
      labels_attributes: [
        {
          text_method: 'build_cached',
          type: labelType.value,
          total: 1
        }
      ]
    })
  }

  return payload
}

async function createCOs(index = 0) {
  currentIndex.value = index + 1
  isSaving.value = true

  if (index < count.value) {
    const identifiers = []

    if (catalogNumber.value.start && catalogNumber.value.namespace?.id) {
      identifiers.push(
        makeIdentifierPayload(
          {
            identifier: catalogNumber.value.start + index,
            namespace: catalogNumber.value.namespace
          },
          IDENTIFIER_LOCAL_CATALOG_NUMBER
        )
      )
    }

    if (recordNumber.value.start && recordNumber.value.namespace?.id) {
      identifiers.push(
        makeIdentifierPayload(
          {
            identifier: recordNumber.value.start + index,
            namespace: recordNumber.value.namespace
          },
          IDENTIFIER_LOCAL_RECORD_NUMBER
        )
      )
    }

    const co = {
      total: 1,
      repository_id: repositoryId.value,
      preparation_type_id: preparationType.value,
      collecting_event_id: props.ceId,
      tags_attributes: tagList.value.map((tag) => ({ keyword_id: tag.id })),
      identifiers_attributes: identifiers
    }

    await CollectionObject.create({ collection_object: co, extend }).then(
      ({ body }) => {
        const promises = [
          ...determinations.value.map((determination) =>
            TaxonDetermination.create({
              taxon_determination: {
                ...determination,
                taxon_determination_object_id: body.id,
                taxon_determination_object_type: COLLECTION_OBJECT
              }
            })
          ),
          ...biocurations.value.map((biocurationId) =>
            BiocurationClassification.create({
              biocuration_classification: {
                biocuration_class_id: biocurationId,
                biocuration_classification_object_id: body.id,
                biocuration_classification_object_type: COLLECTION_OBJECT
              }
            })
          )
        ]

        index++

        Promise.all(promises).then(() => {
          createCOs(index)
        })
      },
      (error) => {
        noCreated.value.unshift({
          label: identifiers
            .map((item) => `${item.namespace.name} ${item.identifer}`)
            .join('; '),
          error: error.body
        })
        index++
        createCOs(index)
      }
    )
  } else {
    isSaving.value = false
    loadTable()
  }
}

function loadTable() {
  const params = {
    collecting_event_id: [props.ceId],
    extend
  }

  isLoading.value = true
  CollectionObject.where(params).then((response) => {
    list.value = response.body
    isLoading.value = false
  })
}

function handleClick() {
  noCreated.value = []
  createCOs(0)
}
</script>
