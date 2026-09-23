<template>
  <div>
    <VSpinner
      v-if="isProcessing"
      legend="Updating..."
    />

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
      <smart-selector
        class="separate-bottom"
        :options="options"
        v-model="view"
      />
      <tree-display
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
      <autocomplete
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
        Selected: <b>{{ selectedType.name }}</b>
        <VBtn
          circle
          color="destroy"
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
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <VBtn
        color="primary"
        :disabled="!canSubmit"
        @click="openModal"
      >
        {{ buttonLabel }}
      </VBtn>
    </div>

    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import SmartSelector from '@/components/ui/VSwitch'
import Autocomplete from '@/components/ui/Autocomplete'
import FormCitation from '@/components/Form/FormCitation.vue'
import TreeDisplay from '@/tasks/nomenclature/filter/components/treeDisplay.vue'
import makeCitation from '@/factory/Citation'
import { TaxonNameClassification } from '@/routes/endpoints'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { TAXON_NAME, TAXON_NAME_CLASSIFICATION } from '@/constants'
import { ref, computed, onMounted } from 'vue'
import { capitalize } from '@/helpers/strings'

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

const confirmationModalRef = ref(null)
const isProcessing = ref(false)
const selectedMode = ref(null)
const selectedType = ref(undefined)
const statusList = ref({})
const mergeLists = ref({})
const view = ref(OPTIONS.common)
const citation = ref(makeCitation(TAXON_NAME_CLASSIFICATION))

const options = computed(() => Object.values(OPTIONS))

const canSubmit = computed(() => !!selectedMode.value && !!selectedType.value)

const buttonLabel = computed(() => {
  if (!selectedType.value) {
    return selectedMode.value === 'remove' ? 'Remove status' : 'Add status'
  }
  return selectedMode.value === 'remove'
    ? `Remove ${selectedType.value.name}`
    : `Add ${selectedType.value.name}`
})

onMounted(() => {
  TaxonNameClassification.types().then(({ body }) => {
    statusList.value = body
    merge()
  })
})

function merge() {
  const newList = { all: {}, common: {}, tree: {} }

  Object.keys(statusList.value).forEach((key) => {
    // Gender and part-of-speech classifications have their own dedicated
    // handling (single-value-per-name semantics, cached spelling side
    // effects) and are deliberately excluded here, same as ClassificationMain.vue.
    if (key === 'latinized') return

    const group = statusList.value[key]
    newList.all = { ...newList.all, ...group.all }
    newList.tree = { ...newList.tree, ...group.tree }

    // Common entries are merged across nomenclatural codes, so qualify the
    // label with the code (e.g. "Fossil (iczn)") to disambiguate identically
    // named statuses from different codes (see FacetStatus.vue's merge()).
    Object.keys(group.common).forEach((type) => {
      newList.common[type] = {
        ...group.common[type],
        name: `${group.common[type].name} (${key})`
      }
    })
  })

  getTreeList(newList.tree, newList.all)
  mergeLists.value = newList
}

function getTreeList(list, ranksList) {
  for (const key in list) {
    if (key in ranksList) {
      Object.defineProperty(list[key], 'type', {
        writable: true,
        value: key
      })
      Object.defineProperty(list[key], 'name', {
        writable: true,
        value: ranksList[key].name
      })
    }
    getTreeList(list[key], ranksList)
  }
}

function selectType(item) {
  selectedType.value = item
  view.value = OPTIONS.common
}

async function openModal() {
  const isRemove = selectedMode.value === 'remove'
  const ok = await confirmationModalRef.value.show({
    title: 'Status',
    message: `Are you sure you want to ${isRemove ? 'remove' : 'add'} the status "${selectedType.value.name}" ${isRemove ? 'from' : 'to'} all taxon names in the filter result?`,
    confirmationWord: isRemove ? 'REMOVE' : 'ADD',
    okButton: capitalize(buttonLabel.value),
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (!ok) return

  const params = { type: selectedType.value.type }

  if (!isRemove && citation.value.source_id) {
    params.citation = {
      source_id: citation.value.source_id,
      pages: citation.value.pages,
      is_original: citation.value.is_original
    }
  }

  const payload = {
    filter_query: { [QUERY_PARAM[TAXON_NAME]]: props.parameters },
    mode: isRemove ? 'remove_status' : 'add_status',
    params
  }

  isProcessing.value = true

  TaxonNameClassification.batchByFilter(payload)
    .then(({ body }) => {
      const count = body.async ? body.total_attempted : body.updated.length

      const message = body.async
        ? `${count} taxon names queued for status update.`
        : isRemove
          ? `Status removed from ${count} taxon names.`
          : `Status added to ${count} taxon names.`

      TW.workbench.alert.create(message, 'notice')
      emit('close')
    })
    .catch(() => {})
    .finally(() => {
      isProcessing.value = false
    })
}
</script>
