<template>
  <div class="horizontal-left-content align-start">
    <div class="field separate-right full_width">
      <label>Field</label>
      <br />
      <select
        class="normal-input full_width"
        v-model="selectedField"
      >
        <template
          v-for="name in fieldNames"
          :key="name"
        >
          <option :value="{ name, type: fields[name] }">
            {{ name }}
          </option>
        </template>
      </select>
    </div>
  </div>
  <AttributeForm
    v-if="selectedField"
    class="horizontal-left-content"
    :field="selectedField"
    @add="addField"
  />
  <div class="margin-large-bottom">
    <label>
      <input
        type="radio"
        v-model="params.attribute_between_between_and_or"
        value="undefined"
      />
      And
    </label>
    <label class="margin-small-left">
      <input
        type="radio"
        v-model="params.attribute_between_between_and_or"
        value="or"
      />
      Or
    </label>
    <span class="small-text margin-small-left">results from different rows</span>
  </div>
  <table
    v-if="selectedFields.length"
    class="full_width"
  >
    <thead>
      <tr>
        <th>Field</th>
        <th>Value</th>
        <th class="w-2">Exact</th>
        <th class="w-2" />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(field, index) in selectedFields"
        :key="field.param"
      >
        <td>{{ field.param }}</td>
        <td>{{ field.value }}</td>
        <td>
          <input
            v-if="allowExactForField(field)"
            v-model="field.exact"
            type="checkbox"
          />
          <template v-else-if="field.any">Any</template>
          <template v-else-if="!field.value">Empty</template>
          <template v-else>Substring</template>
        </td>
        <td>
          <VBtn
            color="primary"
            circle
            @click="() => removeField(index)"
          >
            <VIcon
              name="trash"
              x-small
            />
          </VBtn>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { ref, watch, onBeforeMount } from 'vue'
import ajaxCall from '@/helpers/ajaxCall'
import AttributeForm from '@/components/Filter/Facets/CollectingEvent/FacetCollectingEvent/AttributeForm.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

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

const emit = defineEmits(['update:modelValue'])

const fields = ref({})
const fieldNames = ref([])
const selectedFields = ref([])
const selectedField = ref(undefined)

function makeAttributeParam(item) {
  return `${item.param}:${item.value}`
}

watch(
  selectedFields,
  (newVal) => {
    params.value.any_value_attribute = newVal
      .filter((item) => item.any)
      .map((item) => item.param)

    params.value.no_value_attribute = newVal
      .filter((item) => !item.value && !item.any)
      .map((item) => item.param)

    params.value.attribute_exact_pair = newVal
      .filter((item) => !item.any && item.exact && item.value)
      .map(makeAttributeParam)

    params.value.attribute_wildcard_pair = newVal
      .filter((item) => !item.any && !item.exact && item.value)
      .map(makeAttributeParam)
  },
  { deep: true }
)

watch(
  () => props.modelValue,
  (newVal) => {
    if (
      !newVal.attribute_exact_pair &&
      !newVal.attribute_wildcard_pair &&
      !newVal.any_value_attribute &&
      !newVal.no_value_attribute
    ) {
      selectedFields.value = []
    }
  }
)

function parsePair(str) {
  const index = str.indexOf(':')
  if (index === -1) return null

  return {
    param: str.slice(0, index),
    value: str.slice(index + 1)
  }
}

onBeforeMount(async () => {
  const { body } = await ajaxCall('get', `/${props.controller}/attributes`)

  const includedAttributes = body.filter(
    ({ name }) => !props.exclude.includes(name)
  )

  fields.value = {}

  const exactPairs = params.value.attribute_exact_pair?.map(parsePair) || []
  const wildcardPairs =
    params.value.attribute_wildcard_pair?.map(parsePair) || []
  const allPairs = [...exactPairs, ...wildcardPairs]

  const selected = []

  includedAttributes.forEach(({ name, type }) => {
    fields.value[name] = type

    const value = allPairs.find(({ param }) => param === name)?.value

    const noValue = params.value.no_value_attribute?.includes(name)
    const any = params.value.any_value_attribute?.includes(name)

    if (value === undefined && !noValue && !any) {
      return
    }

    const exact =
      !!value && !any && exactPairs.some(({ param }) => param === name)

    selected.push({
      param: name,
      value,
      type,
      any,
      exact
    })
  })

  selectedFields.value = selected
  fieldNames.value = Object.keys(fields.value).sort()
})

function addField(field) {
  selectedFields.value = selectedFields.value.filter((f) => {
    return (
      !(field.any && f.param === field.param) &&
      !(!field.any && !field.value && f.param === field.param && f.any)
    )
  })

  const index = selectedFields.value.findIndex((f) => {
    if (field.any) {
      return f.param === field.param && f.any
    }

    if (
      field.value === '' ||
      field.value === null ||
      field.value === undefined
    ) {
      return (
        f.param === field.param &&
        (f.value === '' || f.value === null || f.value === undefined)
      )
    }

    return f.param === field.param && f.value === field.value
  })

  const newField = { ...field, exact: false }

  if (index === -1) {
    selectedFields.value.push(newField)
  } else {
    selectedFields.value[index] = newField
  }

  selectedField.value = undefined
}

function removeField(index) {
  selectedFields.value.splice(index, 1)
}

function allowExactForField(field) {
  const type = field.type

  return (
    !!field.value &&
    !field.any && // i.e. not none, not any
    (type === 'string' ||
      type === 'text' ||
      type === 'integer' ||
      type === 'decimal')
  )
}
</script>
