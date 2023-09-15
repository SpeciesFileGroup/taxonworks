<template>
  <FacetContainer>
    <h3>Import attributes</h3>
    <AddInternalPredicate @add="(p) => predicates.push(p)" />
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
import TablePredicate from '../FacetDataAttribute/TablePredicate.vue'
import TableValue from '../FacetDataAttribute/TableValue.vue'
import AddInternalPredicate from './AddInternalPredicate.vue'
import AddValue from '../FacetDataAttribute/AddValue.vue'
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
    params.value.data_attribute_import_predicate = newVal
      .filter((p) => p.any)
      .map((p) => p.predicate)
    params.value.data_attribute_import_exact_pair = newVal
      .filter((p) => !p.any && p.exact && p.text.length)
      .map((p) => `${p.predicate}:${p.text}`)
    params.value.data_attribute_wildcard_pair = newVal
      .filter((p) => !p.any && !p.exact && p.text.length)
      .map((p) => `${p.predicate}:${p.text}`)
  },
  { deep: true }
)

watch(
  values,
  (newVal) => {
    params.value.data_attribute_import_exact_value = newVal
      .filter((item) => item.exact)
      .map((item) => item.text)
    params.value.data_attribute_import_wildcard_value = newVal
      .filter((item) => !item.exact)
      .map((item) => item.text)
  },
  { deep: true }
)

watch(
  [
    () => props.modelValue.data_attribute_import_exact_pair,
    () => props.modelValue.data_attribute_import_exact_value,
    () => props.modelValue.data_attribute_import_predicate,
    () => props.modelValue.data_attribute_import_wildcard
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
    () => props.modelValue.data_attribute_import_exact_value,
    () => props.modelValue.data_attribute_import_wildcard_value
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
    predicate: p.predicate,
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

onBeforeMount(async () => {
  const predicateWithValues = parsedPredicateParam(
    params.value.data_attribute_import_wildcard_pair || []
  )
  const predicateWithValuesExact = parsedPredicateParam(
    params.value.data_attribute_import_exact_pair || []
  )
  const predicateWithAnyValues =
    params.value.data_attribute_import_predicate || []

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

  predicateWithAnyValues.forEach((predicate) => {
    addPredicate({ predicate, text: '', any: true })
  })

  predicateWithValues.forEach(([predicate, text]) => {
    addPredicate({ predicate, text })
  })

  predicateWithValuesExact.forEach(([predicate, text]) => {
    addPredicate({ predicate, text, exact: true })
  })
})
</script>
