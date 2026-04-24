<template>
  <div class="flex-col gap-medium">
    <template
      v-for="(attribute, index) in attributes"
      :key="attribute.uuid"
    >
      <ByAttributeRow
        :attribute="attribute"
        :field-names="fields"
        :remove-button="attributes.length > 1"
        @remove="() => attributes.splice(index, 1)"
        @add="() => attributes.splice(index + 1, 0, makeAttribute())"
      />
    </template>
  </div>
</template>

<script setup>
import { ref, watch, onBeforeMount } from 'vue'
import ajaxCall from '@/helpers/ajaxCall'
import { randomUUID } from '@/helpers'
import ByAttributeRow from './ByAttributeRow.vue'

const props = defineProps({
  controller: {
    type: String,
    required: true
  },

  exclude: {
    type: Array,
    default: () => []
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const fields = ref({})
const attributes = ref([makeAttribute()])

function makeAttribute(baseObject = {}) {
  return {
    uuid: randomUUID(),
    fieldName: null,
    value: '',
    type: 'exact',
    negator: false,
    logic: null,
    ...baseObject
  }
}

watch(
  attributes,
  (newVal) => {
    const rows = newVal.filter((row) => {
      return row.fieldName || row.negator || row.value || row.type !== 'exact'
    })

    const hasRows = rows.length > 0
    const paramValues = {
      attribute_name: [],
      attribute_value: [],
      attribute_value_negator: [],
      attribute_value_type: [],
      attribute_combine_logic: []
    }

    if (hasRows) {
      rows.forEach((row) => {
        paramValues.attribute_name.push(row.fieldName ?? '')
        paramValues.attribute_value.push(row.value ?? '')
        paramValues.attribute_value_negator.push(row.negator ?? '')
        paramValues.attribute_value_type.push(row.type)
        paramValues.attribute_combine_logic.push(row.logic ?? '')
      })
    }

    Object.assign(params.value, paramValues)
  },
  { deep: true }
)

watch(
  [
    () => params.value.attribute_name,
    () => params.value.attribute_value,
    () => params.value.attribute_value_negator,
    () => params.value.attribute_value_type,
    () => params.value.attribute_combine_logic
  ],
  (newVals, oldVals) => {
    if (
      newVals.every((value) => !value?.length) &&
      oldVals.some((value) => value?.length)
    ) {
      attributes.value = [makeAttribute()]
    }
  },
  { deep: true }
)

onBeforeMount(async () => {
  const {
    attribute_name: names = [],
    attribute_value: values = [],
    attribute_value_negator: negators = [],
    attribute_value_type: types = [],
    attribute_combine_logic: logic = []
  } = params.value

  const { body } = await ajaxCall('get', `/${props.controller}/attributes`)
  const includedAttributes = body.filter(
    ({ name }) => !props.exclude.includes(name)
  )

  fields.value = Object.fromEntries(
    includedAttributes
      .slice()
      .sort((a, b) => a.name.localeCompare(b.name))
      .map(({ name, type }) => [name, type])
  )

  const minLength = Math.min(
    names.length,
    values.length,
    negators.length,
    types.length,
    logic.length
  )

  if (minLength) {
    attributes.value = Array.from({ length: minLength }, (_, i) =>
      makeAttribute({
        fieldName: fields.value[names[i]] ? names[i] : null,
        value: values[i],
        negator: negators[i] || false,
        type: types[i],
        logic: logic[i]
      })
    )
  }
})
</script>
