<template>
  <div class="custom_attributes">
    <fieldset>
      <VSpinner v-if="isLoading" />
      <legend>Custom attributes</legend>
      <template v-if="predicatesList.length">
        <PredicateRow
          v-for="item in predicatesList"
          ref="rowRefs"
          :key="item.id"
          :object-id="objectId"
          :object-type="objectType"
          :predicate-object="item"
          :existing="findExisting(item.id)"
          @on-update="addDataAttribute"
        />
      </template>
      <a
        v-else
        href="/tasks/projects/preferences/index"
        >Select visible predicates
      </a>
    </fieldset>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner'
import PredicateRow from './components/predicateRow'
import {
  Project,
  ControlledVocabularyTerm,
  DataAttribute
} from '@/routes/endpoints'
import { addToArray } from '@/helpers/arrays'
import { DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE, PREDICATE } from '@/constants'
import { ref, watch } from 'vue'

const props = defineProps({
  model: {
    type: String,
    required: true
  },

  objectId: {
    type: Number,
    default: undefined
  },

  objectType: {
    type: String,
    required: true
  },

  modelPreferences: {
    type: Array,
    required: false
  }
})

const emit = defineEmits(['onUpdate'])

const rowRefs = ref([])
const isLoading = ref(true)
const list = ref([])
const dataAttributes = ref([])
const modelPreferencesIds = ref()
const predicatesList = ref([])
const sortedIds = ref([])

watch(() => props.objectId, loadDataAttributes, {
  immediate: true
})

function loadDataAttributes() {
  dataAttributes.value = []
  list.value = []
  resetRows()

  if (props.objectType && props.objectId) {
    isLoading.value = true
    DataAttribute.where({
      attribute_subject_type: props.objectType,
      attribute_subject_id: props.objectId,
      type: DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE
    })
      .then((response) => {
        list.value = response.body
      })
      .finally(() => {
        isLoading.value = false
      })
  }
}

function resetRows() {
  rowRefs.value.forEach((row) => row.reset())
}

async function loadPredicates(ids) {
  isLoading.value = true

  predicatesList.value = ids?.length
    ? (
        await ControlledVocabularyTerm.where({
          type: [PREDICATE],
          id: ids
        })
      ).body
    : []

  predicatesList.value.sort(
    (a, b) => sortedIds.value.indexOf(a.id) - sortedIds.value.indexOf(b.id)
  )

  isLoading.value = false
}

function findExisting(id) {
  return list.value.find((item) => item.controlled_vocabulary_term_id === id)
}

function addDataAttribute(dataAttribute) {
  addToArray(dataAttributes.value, dataAttribute, {
    property: 'controlled_vocabulary_term_id'
  })
  emit('onUpdate', dataAttributes.value)
}

Project.preferences().then((response) => {
  const modelPredicateSets = response.body.model_predicate_sets

  modelPreferencesIds.value = modelPredicateSets[props.model]
  sortedIds.value = modelPredicateSets?.predicate_index || []
  loadPredicates(modelPreferencesIds.value)
})

defineExpose({
  loadDataAttributes,
  resetRows
})
</script>

<style lang="scss">
.custom_attributes {
  input {
    width: 100%;
  }
  .vue-autocomplete-input {
    width: 100% !important;
  }
}
</style>
