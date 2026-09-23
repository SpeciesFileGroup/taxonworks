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

    // getTreeList (below) stamps each tree node's display name from
    // group.all; do that per group before qualifying names, since the tree
    // view (recursiveList.vue) already appends its own code suffix from
    // item.type - qualifying first would double it up ("Fossil (iczn) (Iczn)").
    getTreeList(group.tree, group.all)
    newList.tree = { ...newList.tree, ...group.tree }

    // "All"/"common" entries have no disambiguation of their own (unlike the
    // tree view), so qualify each label with the code (e.g. "Fossil (iczn)")
    // to tell identically named statuses from different codes apart (see
    // FacetStatus.vue's merge()).
    Object.keys(group.all).forEach((type) => {
      newList.all[type] = {
        ...group.all[type],
        name: `${group.all[type].name} (${key})`
      }
    })

    Object.keys(group.common).forEach((type) => {
      newList.common[type] = {
        ...group.common[type],
        name: `${group.common[type].name} (${key})`
      }
    })
  })

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
      `Status ${action} ${updatedCount} taxon names, ${notUpdatedCount} not updated - see details below.`,
      'notice'
    )
  } else {
    TW.workbench.alert.create(
      `No taxon names updated (${notUpdatedCount} not updated) - see details below.`,
      'error'
    )
  }
}
</script>
