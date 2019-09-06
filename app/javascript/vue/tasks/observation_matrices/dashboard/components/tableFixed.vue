<template>
  <div>
    <div class="header-box middle">
      <select class="normal-input">
        <option
          v-for="field in fieldset"
          :key="field.value"
          :value="field.value">
          {{ field.label }}
        </option>
      </select>
      <button
        type="button"
        class="button normal-input button-default">
        Set
      </button>
    </div>
    <table 
      v-if="Object.keys(tableObject)"
      class="full_width">
      <thead>
        <draggable v-model="tableObject.headers" tag="tr" draggable=".th-draggable">
          <th v-for="header in tableObject.headers" :key="header" scope="col" class="th-draggable">
            {{ header }}
          </th>
          <th>Code for matrix</th>
          <th>Code</th>
        </draggable>
      </thead>
      <tbody>
        <tr v-for="row in tableObject.objects">
          <td v-for="(item, key, index) in row">
            {{ row[tableObject.headers[index]] }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'

export default {
  components: {
    Draggable
  },
  props: {
    tableValues: {
      type: Object,
      default: () => { return {} }
    }
  },
  data () {
    return {
      fieldset: [
        {
          label: 'Observations',
          value: 'observations',
          set: ['observation_count', 'observation_depictions', 'descriptors_scored']
        },
        {
          label: 'Observation depictions',
          value: 'depictions'
        }
      ],
      selectedFieldSet: {
        label: 'Observations',
        value: 'observations',
        set: ['observation_count', 'observation_depictions', 'descriptors_scored']
      },
      tableObject: {}
    }
  },
  watch: {
    tableValues: {
      handler (newVal) {
        this.tableObject = this.convertTable(newVal)
      },
      deep: true
    }
  },
  methods: {
    isFiltered (value) {
      if (!this.selectedFieldSet) return
      return this.selectedFieldSet.set.includes(value)
    },
    convertTable (table) {
      let values = {
        headers: table.column_headers.filter(header => { return this.isFiltered(header) }),
        objects: []
      }

      table.data.forEach(row => {
        let object = {}
        row.forEach((item, index) => {
          if (this.isFiltered(table.column_headers[index])) {
            object[table.column_headers[index]] = item
          }
        })
        values.objects.push(object)
      })
      return values
    }
  }
}
</script>
