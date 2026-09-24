<template>
  <div>
    <fieldset>
      <legend>Action</legend>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              name="status_mode"
              value="add"
              v-model="selectedMode"
            />
            Add status
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              name="status_mode"
              value="remove"
              v-model="selectedMode"
            />
            Remove status
          </label>
        </li>
      </ul>
    </fieldset>

    <fieldset v-if="selectedMode">
      <legend>Status</legend>
      <SmartSelector
        class="separate-bottom"
        :options="options"
        v-model="view"
      />
      <TreeDisplay
        v-if="view === OPTIONS.all"
        @close="view = OPTIONS.common"
        :object-lists="mergeLists"
        modal-title="Status"
        display="name"
        @selected="selectType"
      />
      <ul
        v-if="view === OPTIONS.common"
        class="no_bullets"
      >
        <li
          v-for="(item, key) in mergeLists.common"
          :key="key"
        >
          <label>
            <input
              type="radio"
              name="status_type"
              :checked="selectedType?.type === item.type"
              @click="selectType(item)"
            />
            {{ item.name }}
          </label>
        </li>
      </ul>
      <Autocomplete
        v-if="view === OPTIONS.advanced"
        url=""
        :array-list="
          Object.keys(mergeLists.all).map((key) => mergeLists.all[key])
        "
        label="name"
        :clear-after="true"
        min="3"
        time="0"
        @get-item="selectType"
        placeholder="Search"
        event-send="autocompleteStatusSelected"
        param="term"
      />
      <p
        v-if="selectedType"
        class="flex-separate middle margin-small-top"
      >
        <b>{{ selectedType.name }}</b>
        <VBtn
          circle
          color="primary"
          @click="selectedType = undefined"
        >
          <VIcon
            name="trash"
            small
          />
        </VBtn>
      </p>
    </fieldset>

    <fieldset v-if="selectedMode === 'add' && selectedType">
      <legend>Citation (optional)</legend>
      <FormCitation
        v-model="citation"
        :klass="TAXON_NAME_CLASSIFICATION"
        :target="TAXON_NAME_CLASSIFICATION"
      />
      <p class="text-muted-color margin-small-top">
        A taxon name with the requested status and the same source, except for a
        different "original" flag, is not updated, and the taxon name is
        reported as not updated.
      </p>
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        :batch-service="TaxonNameClassification.batchByFilter"
        :payload="payload"
        :disabled="!canSubmit"
        :button-label="buttonLabel"
        :confirmation-word="confirmationWord"
        @update="handleUpdateResult"
        @close="emit('close')"
      />
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import SmartSelector from '@/components/ui/VSwitch'
import Autocomplete from '@/components/ui/Autocomplete'
import FormCitation from '@/components/Form/FormCitation.vue'
import TreeDisplay from '@/tasks/nomenclature/filter/components/treeDisplay.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import makeCitation from '@/factory/Citation'
import { mergeStatusList } from '@/helpers/taxonNameClassificationStatusList'
import { TaxonNameClassification } from '@/routes/endpoints'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { TAXON_NAME, TAXON_NAME_CLASSIFICATION } from '@/constants'
import { ref, computed, onMounted } from 'vue'

const OPTIONS = {
  common: 'common',
  advanced: 'advanced',
  all: 'all'
}

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const selectedMode = ref(null)
const selectedType = ref(undefined)
const statusList = ref({})
const mergeLists = ref({})
const view = ref(OPTIONS.common)
const citation = ref(makeCitation(TAXON_NAME_CLASSIFICATION))

const options = computed(() => Object.values(OPTIONS))

const isRemove = computed(() => selectedMode.value === 'remove')

const canSubmit = computed(() => !!selectedMode.value && !!selectedType.value)

const buttonLabel = computed(() => {
  if (!selectedType.value) {
    return isRemove.value ? 'Remove status' : 'Add status'
  }
  return isRemove.value
    ? `Remove ${selectedType.value.name}`
    : `Add ${selectedType.value.name}`
})

const confirmationWord = computed(() => (isRemove.value ? 'REMOVE' : 'ADD'))

const payload = computed(() => {
  const params = { type: selectedType.value?.type }

  if (!isRemove.value && citation.value.source_id) {
    params.citation = {
      source_id: citation.value.source_id,
      pages: citation.value.pages,
      is_original: citation.value.is_original
    }
  }

  return {
    filter_query: { [QUERY_PARAM[TAXON_NAME]]: props.parameters },
    mode: isRemove.value ? 'remove_status' : 'add_status',
    params
  }
})

onMounted(() => {
  TaxonNameClassification.types()
    .then(({ body }) => {
      statusList.value = body
      merge()
    })
    .catch(() => {})
})

function merge() {
  // Gender and part-of-speech classifications have their own dedicated
  // handling (single-value-per-name semantics, cached spelling side
  // effects) and are deliberately excluded here, same as ClassificationMain.vue.
  const codes = Object.keys(statusList.value).filter((key) => key !== 'latinized')

  mergeLists.value = mergeStatusList(statusList.value, { codes, qualifyAll: true })
}

function selectType(item) {
  selectedType.value = item
  view.value = OPTIONS.common
}

function handleUpdateResult(data) {
  if (data.async) {
    TW.workbench.alert.create(
      `${data.total_attempted} taxon names queued for status update.`,
      'notice'
    )
    return
  }

  const updatedCount = data.updated.length
  const notUpdatedCount = data.not_updated.length
  const action = isRemove.value ? 'removed from' : 'added to'

  if (updatedCount > 0 && notUpdatedCount === 0) {
    TW.workbench.alert.create(
      `Status ${action} ${updatedCount} taxon names.`,
      'notice'
    )
  } else if (updatedCount > 0 && notUpdatedCount > 0) {
    TW.workbench.alert.create(
      `Status ${action} ${updatedCount} taxon names, ${notUpdatedCount} not updated.`,
      'notice'
    )
  } else {
    TW.workbench.alert.create(
      `No taxon names updated (${notUpdatedCount} not updated).`,
      'error'
    )
  }
}
</script>
