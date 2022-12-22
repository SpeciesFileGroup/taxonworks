<template>
  <div>
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
      <div
        v-if="selectedField && checkForMatch(selectedField.type)"
        class="field separate-right label-above"
      >
        <label>Exact?</label>
        <input
          :disabled="!checkForMatch(selectedField.type)"
          type="checkbox"
          v-model="exact"
        >
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
  </div>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue'
import { CollectingEvent } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import AttributeForm from './AttributeForm.vue'

const props = defineProps({
  list: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['fields'])
const fields = ref([])
const selectedFields = ref([])
const selectedField = ref(undefined)

watch(
  selectedFields,
  newVal => {
    const matches = newVal.filter(item => !item.exact).map(item => item.param)
    const fields = {
      collecting_event_wildcards: matches
    }

    newVal.forEach(item => {
      fields[item.param] = item.value
    })

    emit('fields', fields)
  },
  { deep: true }
)

watch(
  () => props.list,
  (newVal, oldVal) => {
    if (Object.keys(newVal).length === 0 && Object.keys(oldVal).length > 1) {
      selectedFields.value = []
      selectedField.value = undefined
    }
  })

onBeforeMount(() => {
  CollectingEvent.attributes().then(response => {
    const urlParams = URLParamsToJSON(location.href)

    fields.value = response.body

    if (Object.keys(urlParams).length) {
      fields.value.forEach(field => {
        if (urlParams[field.name]) {
          selectedFields.value.push({
            param: field.name,
            value: urlParams[field.name],
            type: field.type,
            exact: !urlParams.collecting_event_wildcards?.includes(field.name)
          })
        }
      })
    }
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

defineExpose({
  cleanList () {
    selectedFields.value = []
  }
})
</script>
