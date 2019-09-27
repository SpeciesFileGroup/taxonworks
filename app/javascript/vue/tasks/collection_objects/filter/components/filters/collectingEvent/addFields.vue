<template>
  <div>
    <div class="horizontal-left-content">
      <div class="field separate-right">
        <label>Field</label>
        <br>
        <select 
          class="normal-input"
          v-model="selectedField">
          <option 
            v-for="field in fields">
            {{ field }}
          </option>
        </select>
      </div>
      <div class="field separate-right">
        <label>
          Value
        </label>
        <br>
        <input 
          type="text"
          v-model="fieldValue">
      </div>
      <div class="field separate-right">
        <label>
          Exact?
        </label>
        <br>
        <input 
          type="checkbox"
          v-model="exact">
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
export default {
  data () {
    return {
      fields: ['verbatim_locality', 'habitat'],
      exact: false,
      collecting_event_exact_matches: [],
      selectedFields: [],
      selectedField: undefined,
      fieldValue: undefined
    }
  },
  watch: {
    selectedFields: {
      handler (newVal) {
        let matches = newVal.filter(item => { return item.exact }).map(item => { return item.param })
        let fields = {
          collecting_event_exact_matches: matches
        }
        newVal.forEach(item => {
          fields[item.param] = item.value
        })
        this.$emit('fields', fields)
      },
      deep: true
    }
  },
  methods: {
    addField() {
      if(this.exact) {
        this.collecting_event_exact_matches.push(this.selectedField)
      }
      this.selectedFields.push({
        param: this.selectedField,
        value: this.fieldValue,
        exact: this.exact
      })
    },
    removeField(index) {
      this.selectedFields.splice(index, 1)
    }
  }
}
</script>