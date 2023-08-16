<template>
  <FacetContainer>
    <h3>Data attributes</h3>
    <AddPredicate @add="(p) => predicates.push(p)" />
    <TablePredicate
      v-if="predicates.length"
      :predicates="predicates"
      @update="
        ({ index, predicate }) => {
          predicates[index] = predicate
        }
      "
      @remove="
        (index) => {
          predicates.splice(index, 1)
        }
      "
    />
    <hr class="divisor full_width" />
    <AddValue
      @add="
        (value) => {
          values.push(value)
        }
      "
    />
    <TableValue
      v-if="values.length"
      :values="values"
      @update="
        ({ index, value }) => {
          values[index] = value
        }
      "
      @remove="
        (index) => {
          values.splice(index, 1)
        }
      "
    />
  </FacetContainer>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import TablePredicate from './FacetDataAttribute/TablePredicate.vue'
import TableValue from './FacetDataAttribute/TableValue.vue'
import AddPredicate from './FacetDataAttribute/AddPredicate.vue'
import AddValue from './FacetDataAttribute/AddValue.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const predicates = ref([])
const values = ref([])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

watch(
  predicates,
  (newVal) => {
    params.value.data_attribute_predicate_id = newVal
      .filter((p) => p.any)
      .map((p) => p.id)
    params.value.data_attribute_without_predicate_id = newVal
      .filter((p) => !p.any && !p.text)
      .map((p) => p.id)
    params.value.data_attribute_exact_pair = newVal
      .filter((p) => !p.any && p.exact && p.text.length)
      .map((p) => `${p.id}:${p.text}`)
    params.value.data_attribute_wildcard_pair = newVal
      .filter((p) => !p.any && !p.exact && p.text.length)
      .map((p) => `${p.id}:${p.text}`)
  },
  { deep: true }
)

watch(
  values,
  (newVal) => {
    params.value.data_attribute_exact_value = newVal
      .filter((item) => item.exact)
      .map((item) => item.text)
    params.value.data_attribute_wildcard_value = newVal
      .filter((item) => !item.exact)
      .map((item) => item.text)
  },
  { deep: true }
)

watch(
  [
    () => props.modelValue.data_attribute_predicate_id,
    () => props.modelValue.data_attribute_without_predicate_id,
    () => props.modelValue.data_attribute_exact_pair,
    () => props.modelValue.data_attribute_wildcard_pair
  ],
  (newVals, oldVals) => {
    if (
      newVals.every((value) => !value?.length) &&
      oldVals.some((value) => value?.length)
    ) {
      predicates.value = []
    }
  },
  { deep: true }
)

watch(
  [
    () => props.modelValue.data_attribute_exact_value,
    () => props.modelValue.data_attribute_wildcard_value
  ],
  (newVals, oldVals) => {
    if (
      newVals.every((value) => !value?.length) &&
      oldVals.some((value) => value?.length)
    ) {
      values.value = []
    }
  },
  { deep: true }
)

function addPredicate(p) {
  predicates.value.push({
    id: p.id,
    name: p.name,
    exact: p.exact,
    any: p.any,
    text: p.text
  })
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
  const predicatesWithoutValues =
    params.value.data_attribute_without_predicate_id || []
  const predicateWithAnyValues = params.value.data_attribute_predicate_id || []

  values.value = [
    ...(params.value.data_attribute_exact_value || []).map((text) => ({
      text,
      exact: true
    })),
    ...(params.value.data_attribute_wildcard_value || []).map((text) => ({
      text,
      exact: false
    }))
  ]

  const predicateIds = [
    ...predicateWithAnyValues,
    ...predicatesWithoutValues,
    ...predicateWithValues.map(([value]) => value),
    ...predicateWithValuesExact.map(([value]) => value)
  ]

  if (predicateIds.length) {
    const predicateList = (
      await ControlledVocabularyTerm.where({ id: predicateIds })
    ).body

    loadPredicates({
      predicateIds: predicatesWithoutValues,
      predicateList,
      predicateValues: { text: '' }
    })

    loadPredicates({
      predicateIds: predicateWithAnyValues,
      predicateList,
      predicateValues: { text: '', any: true }
    })

    predicateWithValues.forEach(([id, text]) => {
      const p = predicateList.find((item) => item.id === id)
      addPredicate({ ...p, text })
    })

    predicateWithValuesExact.forEach(([id, text]) => {
      const p = predicateList.find((item) => item.id === id)
      addPredicate({ ...p, text, exact: true })
    })
  }
})
</script>
