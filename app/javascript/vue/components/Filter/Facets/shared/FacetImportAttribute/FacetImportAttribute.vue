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
    <TablePredicate
      v-if="attributes.length"
      :predicates="attributes"
      @update="
        ({ index, predicate }) => {
          attributes[index] = predicate
        }
      "
      @remove="
        (index) => {
          attributes.splice(index, 1)
        }
      "
    />
    <div class="margin-medium-top">
      <label>
        <input
          type="radio"
          v-model="params.data_attribute_import_between_and_or"
          value="undefined"
        />
        And
      </label>
      <label class="margin-small-left">
        <input
          type="radio"
          v-model="params.data_attribute_import_between_and_or"
          value="or"
        />
        Or
      </label>
      <span class="small-text margin-small-left">results from different rows</span>
    </div>
  </FacetContainer>
</template>

<script setup>
import { ref, watch, onBeforeMount } from 'vue'
import { randomUUID } from '@/helpers'
import TablePredicate from '../FacetDataAttribute/TablePredicate.vue'
import AddInternalPredicate from './AddInternalPredicate.vue'
import AddValue from '../FacetDataAttribute/AddValue.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const attributes = ref([])

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
