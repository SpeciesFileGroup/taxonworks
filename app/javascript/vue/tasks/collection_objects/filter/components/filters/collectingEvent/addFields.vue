<template>
  <div>
    <h3>By attribute</h3>
    <div class="horizontal-left-content align-start">
      <div class="field separate-right full_width">
        <label>Field</label>
        <br>
        <select
          class="normal-input full_width"
          v-model="selectedField">
          <option
            :value="field"
            :key="field.name"
            v-if="!selectedFields.find(item => item.param === field.name)"
            v-for="field in fields">
            {{ field.name }}
          </option>
        </select>
      </div>
      <div
        v-if="selectedField && checkForMatch(selectedField.type)"
        class="field separate-right">
        <label>
          Exact?
        </label>
        <br>
        <input 
          :disabled="!checkForMatch(selectedField.type)"
          type="checkbox"
          v-model="exact">
      </div>
    </div>
    <div
      v-if="selectedField"
      class="horizontal-left-content">
      <div class="field separate-right full_width">
        <label>
          Value
        </label>
        <br>
        <input
          class="full_width"
          :type="types[selectedField.type]"
          v-model="fieldValue">
      </div>
      <div class="field">
        <label>
           &nbsp;
        </label>
        <br>
        <button
          class="button normal-input button-default"
          type="button"
          @click="addField">
          Add
        </button>
      </div>
    </div>
    <div v-if="selectedFields.length">
      <table class="full_width">
        <thead>
          <tr>
            <th>Field</th>
            <th>Value</th>
            <th>Exact</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(field, index) in selectedFields">
            <td>{{ field.param }}</td>
            <td>{{ field.value }}</td>
            <td>
              <input
                v-if="checkForMatch(field.type)"
                v-model="field.exact"
                type="checkbox">
            </td>
            <td>
              <span
                class="button circle-button btn-delete button-default"
                @click="removeField(index)"/>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>

import { CollectingEvent } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const TYPES = {
  text: 'text',
  string: 'text',
  integer: 'number',
  decimal: 'number'
}

export default {
  props: {
    list: {
      type: Object,
      required: true
    }
  },

  emits: ['fields'],

  computed: {
    types () {
      return TYPES
    }
  },

  data () {
    return {
      fields: ['verbatim_locality', 'habitat'],
      exact: false,
      selectedFields: [],
      selectedField: undefined,
      fieldValue: undefined
    }
  },
  watch: {
    selectedFields: {
      handler (newVal) {
        const matches = newVal.filter(item => { return item.exact }).map(item => { return item.param })
        const fields = {
          collecting_event_wildcards: matches
        }
        newVal.forEach(item => {
          fields[item.param] = item.value
        })
        this.$emit('fields', fields)
      },
      deep: true
    },
    selectedField () {
      this.fieldValue = undefined
    },
    list (newVal, oldVal) {
      if (Object.keys(newVal).length === 0 && Object.keys(oldVal).length > 1) {
        this.selectedFields = []
        this.resetFields()
      }
    }
  },
  mounted () {
    CollectingEvent.attributes().then(response => {
      this.fields = response.body
      const urlParams = URLParamsToJSON(location.href)
      if (Object.keys(urlParams).length) {
        this.fields.forEach((field) => {
          if (urlParams[field.name]) {
            this.selectedFields.push({
              param: field.name,
              value: urlParams[field.name],
              type: field.type,
              exact: urlParams.collecting_event_wildcards ? urlParams.collecting_event_wildcards.includes(field.name) : undefined
            })
          }
        })
      }
    })
  },
  methods: {
    resetFields() {
      this.selectedField = undefined
      this.fieldValue = undefined
      this.exact = undefined
    },
    addField() {
      this.selectedFields.push({
        param: this.selectedField.name,
        value: this.fieldValue,
        type: this.selectedField.type,
        exact: this.exact
      })
      this.resetFields()
    },
    removeField(index) {
      this.selectedFields.splice(index, 1)
    },
    checkForMatch(type) {
      return (type === 'string' || type === 'text')
    },
    cleanList () {
      this.selectedFields = []
    }
  }
}
</script>
