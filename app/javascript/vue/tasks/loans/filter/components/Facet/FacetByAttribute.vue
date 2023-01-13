<template>
  <FacetContainer>
    <h3>By attribute</h3>
    <div class="horizontal-left-content align-start">
      <div class="field separate-right full_width">
        <label>Field</label>
        <br>
        <select
          class="normal-input full_width"
          v-model="selectedField"
        >
          <template
            v-for="field in fields"
            :key="field.name"
          >
            <option
              v-if="!selectedFields.find(item => item.param === field.name)"
              :value="field"
            >
              {{ field.name }}
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

    <div v-if="selectedFields.length">
      <table class="full_width">
        <thead>
          <tr>
            <th>Field</th>
            <th>Value</th>
            <th>Exact</th>
            <th />
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
                v-if="checkForMatch(field.type)"
                v-model="field.exact"
                type="checkbox"
              >
            </td>
            <td>
              <span
                class="button circle-button btn-delete button-default"
                @click="removeField(index)"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </FacetContainer>
</template>

<script setup>
import { ref, watch, computed, onBeforeMount } from 'vue'
import { Loan } from 'routes/endpoints'
import AttributeForm from 'components/Filter/Facets/CollectingEvent/FacetCollectingEvent/AttributeForm.vue'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const fields = ref([])
const selectedFields = ref([])
const selectedField = ref(undefined)

watch(
  selectedFields,
  newVal => {
    const matches = newVal.filter(item => !item.exact).map(item => item.param)
    const attributes = {}

    params.value.loan_wildcards = matches

    fields.value.forEach(({ name }) => {
      attributes[name] = undefined
    })

    newVal.forEach(({ param, value }) => {
      attributes[param] = value
    })

    Object.assign(params.value, attributes)
  },
  { deep: true }
)

watch(
  () => props.modelValue,
  newVal => {
    if (!Object.keys(newVal).length) {
      selectedFields.value = []
    }
  }
)

onBeforeMount(() => {
  Loan.attributes().then(response => {
    fields.value = response.body

    fields.value.forEach(field => {
      if (params.value[field.name]) {
        selectedFields.value.push({
          param: field.name,
          value: params.value[field.name],
          type: field.type,
          exact: !params.value.loan_wildcards?.includes(field.name)
        })
      }
    })
  })
})

const addField = (field) => {
  selectedFields.value.push(field)
  selectedField.value = undefined
}

const removeField = (index) => {
  selectedFields.value.splice(index, 1)
}

const checkForMatch = (type) => {
  return (type === 'string' || type === 'text')
}
</script>
