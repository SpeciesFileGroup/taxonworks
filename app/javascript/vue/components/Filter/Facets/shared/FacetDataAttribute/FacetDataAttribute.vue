<template>
  <FacetContainer v-help="en.facets.dataAttributes">
    <h3>Data attributes</h3>
    <AddPredicate @add="(p) => addPredicate(p)" />

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
      :predicate-without-value="predicateWithoutValue"
      :value-any-predicate="valueAnyPredicate"
      v-model:and-or="params.data_attribute_between_and_or"
      @update="updateAttribute"
      @remove="removeAttribute"
    />
  </FacetContainer>
</template>

<script setup>
import { ref, watch, onBeforeMount, computed } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { vHelp } from '@/directives'
import { en } from '../../../help'
import { randomUUID } from '@/helpers'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import AddPredicate from './AddPredicate.vue'
import AddValue from './AddValue.vue'
import AttributeFacetGroups from './AttributeFacetGroups.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const attributes = ref([])

const predicatePairs = computed(() =>
  attributes.value.filter((a) => a.isPair && !a.any && a.text)
)

const predicateAnyValue = computed(() =>
  attributes.value.filter((a) => a.isPair && a.any)
)

const predicateWithoutValue = computed(() =>
  attributes.value.filter((a) => a.isPair && !a.any && !a.text)
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
      params.value.data_attribute_predicate_id = pair
        .filter((p) => p.any)
        .map((p) => p.id)
      params.value.data_attribute_without_predicate_id = pair
        .filter((p) => !p.any && !p.text)
        .map((p) => p.id)
      params.value.data_attribute_exact_pair = pair
        .filter((p) => !p.any && p.exact && p.text.length)
        .map((p) => `${p.id}:${p.text}`)
      params.value.data_attribute_wildcard_pair = pair
        .filter((p) => !p.any && !p.exact && p.text.length)
        .map((p) => `${p.id}:${p.text}`)
    }

    if (values.length) {
      params.value.data_attribute_exact_value = values
        .filter((item) => item.exact)
        .map((item) => item.text)
      params.value.data_attribute_wildcard_value = values
        .filter((item) => !item.exact)
        .map((item) => item.text)
    }
  },
  { deep: true }
)

watch(
  [
    () => params.value.data_attribute_predicate_id,
    () => params.value.data_attribute_without_predicate_id,
    () => params.value.data_attribute_exact_pair,
    () => params.value.data_attribute_wildcard_pair
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
    () => params.value.data_attribute_exact_value,
    () => params.value.data_attribute_wildcard_value
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

function addPredicate(p) {
  attributes.value.push({
    uuid: randomUUID(),
    isPair: true,
    id: p.id,
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

function parsedPredicateParam(param) {
  return param.map((value) => {
    const index = value.indexOf(':')

    return [Number(value.slice(0, index)), value.slice(index + 1)]
  })
}

function loadPredicates({ predicateIds, predicateList, predicateValues }) {
  predicateIds.forEach((id) => {
    const p = predicateList.find((item) => item.id === id)

    if (p) {
      addPredicate({ ...p, ...predicateValues })
    }
  })
}

onBeforeMount(async () => {
  const predicateWithValues = parsedPredicateParam(
    params.value.data_attribute_wildcard_pair || []
  )
  const predicateWithValuesExact = parsedPredicateParam(
    params.value.data_attribute_exact_pair || []
  )
  const predicatesWithout =
    params.value.data_attribute_without_predicate_id?.map(Number) || []
  const predicateWithAnyValues = params.value.data_attribute_predicate_id || []

  const exactValues = params.value.data_attribute_exact_value || []
  const wildcardValues = params.value.data_attribute_wildcard_value || []

  exactValues.forEach((text) =>
    addValue({
      text,
      exact: true
    })
  )

  wildcardValues.map((text) =>
    addValue({
      text,
      exact: false
    })
  )

  const predicateIds = [
    ...predicateWithAnyValues,
    ...predicatesWithout,
    ...predicateWithValues.map(([value]) => value),
    ...predicateWithValuesExact.map(([value]) => value)
  ]

  if (predicateIds.length) {
    const predicateList = (
      await ControlledVocabularyTerm.where({ id: predicateIds })
    ).body

    loadPredicates({
      predicateIds: predicatesWithout,
      predicateList,
      predicateValues: { text: '', any: false }
    })

    loadPredicates({
      predicateIds: predicateWithAnyValues,
      predicateList,
      predicateValues: { text: '', any: true }
    })

    predicateWithValues.forEach(([id, text]) => {
      const p = predicateList.find((item) => item.id === id)
      addPredicate({ ...p, text, exact: false })
    })

    predicateWithValuesExact.forEach(([id, text]) => {
      const p = predicateList.find((item) => item.id === id)
      addPredicate({ ...p, text, exact: true })
    })
  }
})
</script>
