<template>
  <FacetContainer>
    <h3>Import attributes</h3>
    <AddInternalPredicate @add="(p) => addPredicate(p)" />

    <hr class="divisor full_width" />
    <AddValue
      label="Value (any predicate)"
      @add="
        (value) => {
          addValue(value)
        }
      "
    />

    <AttributeFacetGroups
      :predicate-pairs="predicatePairs"
      :predicate-any-value="predicateAnyValue"
      :predicate-without-value="[]"
      :value-any-predicate="valueAnyPredicate"
      v-model:and-or="params.data_attribute_import_between_and_or"
      @update="updateAttribute"
      @remove="removeAttribute"
    />
  </FacetContainer>
</template>

<script setup>
import { ref, watch, onBeforeMount, computed } from 'vue'
import { randomUUID } from '@/helpers'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import AddInternalPredicate from './AddInternalPredicate.vue'
import AddValue from '../FacetDataAttribute/AddValue.vue'
import AttributeFacetGroups from '../FacetDataAttribute/AttributeFacetGroups.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const attributes = ref([])

// Computed properties to filter attributes by facet type
const predicatePairs = computed(() =>
  attributes.value.filter((a) => a.isPair && !a.any && a.text)
)

const predicateAnyValue = computed(() =>
  attributes.value.filter((a) => a.isPair && a.any)
)

const valueAnyPredicate = computed(() =>
  attributes.value.filter((a) => !a.isPair)
)

const params = defineModel({
  type: Object,
  required: true
})

watch(
  attributes,
  (newVal) => {
    const pair = newVal.filter((a) => a.isPair)
    const values = newVal.filter((a) => !a.isPair)

    if (pair.length) {
      params.value.data_attribute_import_predicate = pair
        .filter((p) => p.any)
        .map((p) => p.name)
      params.value.data_attribute_import_exact_pair = pair
        .filter((p) => !p.any && p.exact && p.text.length)
        .map((p) => `${p.name}:${p.text}`)
      params.value.data_attribute_import_wildcard_pair = pair
        .filter((p) => !p.any && !p.exact && p.text.length)
        .map((p) => `${p.name}:${p.text}`)
    }

    if (values.length) {
      {
        params.value.data_attribute_import_exact_value = values
          .filter((item) => item.exact)
          .map((item) => item.text)
        params.value.data_attribute_import_wildcard_value = values
          .filter((item) => !item.exact)
          .map((item) => item.text)
      }
    }
  },
  { deep: true }
)

watch(
  [
    () => params.value.data_attribute_import_exact_pair,
    () => params.value.data_attribute_import_wildcard_pair,
    () => params.value.data_attribute_import_predicate
  ],
  (newVals, oldVals) => {
    if (
      newVals.every((value) => !value?.length) &&
      oldVals.some((value) => value?.length)
    ) {
      attributes.value = attributes.value.filter((item) => !item.isPair)
    }
  },
  { deep: true }
)

watch(
  [
    () => params.value.data_attribute_import_exact_value,
    () => params.value.data_attribute_import_wildcard_value
  ],
  (newVals, oldVals) => {
    if (
      newVals.every((value) => !value?.length) &&
      oldVals.some((value) => value?.length)
    ) {
      attributes.value = attributes.value.filter((item) => item.isPair)
    }
  },
  { deep: true }
)

function parsedPredicateParam(param) {
  return param.map((value) => {
    const index = value.indexOf(':')

    return [value.slice(0, index), value.slice(index + 1)]
  })
}

function addPredicate(p) {
  attributes.value.push({
    uuid: randomUUID(),
    isPair: true,
    name: p.name,
    exact: p.exact,
    any: p.any,
    text: p.text
  })
}

function addValue({ text, exact }) {
  attributes.value.push({
    uuid: randomUUID(),
    isPair: false,
    text,
    exact
  })
}

function updateAttribute(predicate) {
  addToArray(attributes.value, predicate, { property: 'uuid' })
}

function removeAttribute(predicate) {
  removeFromArray(attributes.value, predicate, { property: 'uuid' })
}

onBeforeMount(async () => {
  const predicateWithValues = parsedPredicateParam(
    params.value.data_attribute_import_wildcard_pair || []
  )
  const predicateWithValuesExact = parsedPredicateParam(
    params.value.data_attribute_import_exact_pair || []
  )
  const predicateWithAnyValues =
    params.value.data_attribute_import_predicate || []

  const exactValues = params.value.data_attribute_import_exact_value || []
  const wildcardValues = params.value.data_attribute_import_wildcard_value || []

  exactValues.forEach((text) =>
    addValue({
      text,
      exact: true
    })
  )
  wildcardValues.forEach((text) =>
    addValue({
      text,
      exact: false
    })
  )

  predicateWithAnyValues.forEach((predicate) => {
    addPredicate({ predicate, name: predicate, text: '', any: true })
  })

  predicateWithValues.forEach(([predicate, text]) => {
    addPredicate({ predicate, name: predicate, text, exact: false })
  })

  predicateWithValuesExact.forEach(([predicate, text]) => {
    addPredicate({ predicate, name: predicate, text, exact: true })
  })
})
</script>
