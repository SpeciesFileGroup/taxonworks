<template>
  <div>
    <div>
      <VSpinner
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
        Add/Current ({{ pagination.total || 0 }})
      </button>
    </div>
    <VModal
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
        <h3>Create Field occurrences</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start">
          <VSpinner
            v-if="isLoading || isSaving"
            :legend="
              isSaving
                ? `Creating ${currentIndex} of ${count} field occurrence(s)...`
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
            <BiocurationComponent
              class="margin-medium-bottom panel content"
              v-model="biocurations"
            />
            <DeterminerComponent
              class="margin-medium-bottom panel content"
              v-model="determinations"
            />
            <TagComponent
              class="margin-medium-bottom panel content"
              v-model="tagList"
            />
          </div>
          <div class="panel content flex-grow-2">
            <span
              >{{ list.length }} object(s) are already associated with this
              collecting event</span
            >
            <h3>Existing</h3>
            <VPagination
              :pagination="pagination"
              @next-page="({ page }) => loadTable(page)"
            />
            <table class="full_width table-striped">
              <thead>
                <tr>
                  <th>ID</th>
                  <th class="full_width">Field occurrence</th>
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
                  <td v-html="item.object_tag" />

                  <td>
                    <div
                      v-if="item.global_id"
                      class="horizontal-left-content gap-small"
                    >
                      <RadialAnnotator :global-id="item.global_id" />
                      <RadialObject :global-id="item.global_id" />
                      <RadialNavigation :global-id="item.global_id" />
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigation from '@/components/radials/navigation/radial'
import RadialObject from '@/components/radials/object/radial.vue'
import VModal from '@/components/ui/Modal'
import VSpinner from '@/components/ui/VSpinner'
import VPagination from '@/components/pagination.vue'

import BiocurationComponent from '../ModalCollectionObjects/Biocuration'
import DeterminerComponent from '../ModalCollectionObjects/Determiner'
import TagComponent from '../ModalCollectionObjects/Tags'

import { FieldOccurrence } from '@/routes/endpoints'
import { ref, watch } from 'vue'
import { getPagination } from '@/helpers'

const extend = ['taxon_determinations']
const per = 50

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
const determinations = ref([])
const isSaving = ref(false)
const tagList = ref([])
const count = ref(1)
const pagination = ref({})

watch(
  () => props.ceId,
  (newVal) => {
    if (newVal) {
      loadTable()
    } else {
      list.value = []
      pagination.value = {}
    }
  }
)

async function createFOs(index = 0) {
  currentIndex.value = index + 1
  isSaving.value = true

  if (index < count.value) {
    const payload = {
      field_occurrence: {
        total: 1,
        collecting_event_id: props.ceId,
        tags_attributes: tagList.value.map((tag) => ({ keyword_id: tag.id })),
        taxon_determinations_attributes: determinations.value,
        biocuration_classifications_attributes: biocurations.value.map(
          (biocurationId) => ({ biocuration_class_id: biocurationId })
        )
      },
      extend
    }

    await FieldOccurrence.create(payload)
      .catch(() => {})
      .finally(() => {
        index++
        createFOs(index)
      })
  } else {
    isSaving.value = false
    loadTable()
  }
}

function loadTable(page = 1) {
  const params = {
    collecting_event_id: [props.ceId],
    per,
    page,
    extend
  }

  isLoading.value = true
  FieldOccurrence.where(params).then((response) => {
    list.value = response.body
    isLoading.value = false
    pagination.value = getPagination(response)
  })
}

function handleClick() {
  createFOs(0)
}
</script>
