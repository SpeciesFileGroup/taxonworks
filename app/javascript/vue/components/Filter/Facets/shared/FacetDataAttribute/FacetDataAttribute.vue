<template>
  <FacetContainer v-help="en.facets.dataAttributes">
    <h3>Data attributes</h3>

    <div class="flex-col gap-medium">
      <template v-for="(da, index) in dataAttributes">
        <DataAttributeRow
          :data-attribute="da"
          :remove-button="dataAttributes.length > 1"
          :predicates="predicates"
          @remove="() => dataAttributes.splice(index, 1)"
          @add="() => dataAttributes.splice(index + 1, 0, makeDataAttribute())"
        />
      </template>
    </div>
  </FacetContainer>
</template>

<script setup>
import { ref, watch, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { vHelp } from '@/directives'
import { en } from '../../../help'
import { randomUUID } from '@/helpers'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import DataAttributeRow from './DataAttributeRow/DataAttributeRow.vue'
import { PREDICATE } from '@/constants'

const predicates = ref([])
const dataAttributes = ref([makeDataAttribute()])

function makeDataAttribute(baseObject = {}) {
  return {
    uuid: randomUUID(),
    type: 'exact',
    value: null,
    predicate: null,
    negator: false,
    logic: null,
    ...baseObject
  }
}

const params = defineModel({
  type: Object,
  required: true
})

watch(
  dataAttributes,
  (newVal) => {
    const attributes = newVal.filter((da) => {
      // Require something other than the default
      return da.predicate || da.negator || da.value || da.type != 'exact'
    })
    const hasAttributes = attributes.length > 0

    const paramValues = {
      data_attribute_predicate_id: [],
      data_attribute_value: [],
      data_attribute_value_negator: [],
      data_attribute_value_type: [],
      data_attribute_combine_logic: []
    }

    if (hasAttributes) {
      attributes.forEach((a) => {
        paramValues.data_attribute_predicate_id.push(a.predicate?.id ?? '')
        paramValues.data_attribute_value.push(a.value ?? '')
        paramValues.data_attribute_value_negator.push(a.negator ?? '')
        paramValues.data_attribute_value_type.push(a.type)
        paramValues.data_attribute_combine_logic.push(a.logic ?? '')
      })
    }

    Object.assign(params.value, paramValues)
  },
  { deep: true }
)

watch(
  [
    () => params.value.data_attribute_predicate_id,
    () => params.value.data_attribute_value,
    () => params.value.data_attribute_combine_logic,
    () => params.value.data_attribute_value_type,
    () => params.value.data_attribute_value_negator
  ],
  (newVals, oldVals) => {
    if (
      newVals.every((value) => !value?.length) &&
      oldVals.some((value) => value?.length)
    ) {
      dataAttributes.value = [makeDataAttribute()]
    }
  },
  { deep: true }
)

onBeforeMount(async () => {
  const {
    data_attribute_predicate_id: predicateId = [],
    data_attribute_value: values = [],
    data_attribute_combine_logic: logic = [],
    data_attribute_value_type: type = [],
    data_attribute_value_negator: negator = []
  } = params.value

  const minLength = Math.min(
    predicateId.length,
    values.length,
    logic.length,
    type.length,
    negator.length
  )

  predicates.value = (
    await ControlledVocabularyTerm.all({ type: [PREDICATE] })
  ).body

  if (minLength) {
    dataAttributes.value = Array.from({ length: minLength }, (_, i) =>
      makeDataAttribute({
        predicate: predicates.value.find((p) => p.id == predicateId[i]),
        value: values[i],
        logic: logic[i],
        type: type[i],
        negator: negator[i] || false
      })
    )
  }
})
</script>
