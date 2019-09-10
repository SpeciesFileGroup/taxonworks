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
        class="button normal-input button-default separate-left">
        Set
      </button>
    </div>
    <table 
      v-if="Object.keys(tableObject)"
      class="full_width">
      <thead>
        <draggable v-model="tableObject.headers" tag="tr" draggable=".th-draggable">
          <th
            v-for="header in tableObject.headers"
            :key="header"
            scope="col"
            @click="sortBy(header)"
            class="th-draggable"
            :class="{ headerSortDown: headersOrder.includes(header), headerSortUp: !headersOrder.includes(header) }">
            <span v-html="header.replace('_', '<br>')"/>
          </th>
          <th>Code</th>
        </draggable>
      </thead>
      <tbody>
        <tr v-for="(row, rowIndex) in tableObject.objects">
          <td v-for="(item, key, index) in row">
            {{ row[tableObject.headers[index]] }}
          </td>
          <td>
            <modal-list
              :otu-id="getValueFromTable('otu_id', rowIndex)"
              :taxon-id="getValueFromTable('taxon_name_id', rowIndex)"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import modalList from './modalList'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    Draggable,
    modalList
  },
  computed: {
    tableValues: {
      get () {
        return this.$store.getters[GetterNames.GetRankTable]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRankTable)
      }
    }
  },
  data () {
    return {
      fieldset: [
        {
          label: 'Observations',
          value: 'observations',
          set: ['observation_count', 'observation_depictions', 'descriptors_scored']
        }
      ],
      selectedFieldSet: {
        label: 'Observations',
        value: 'observations',
        set: ['observation_count', 'observation_depictions', 'descriptors_scored']
      },
      tableObject: {},
      headersOrder: []
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
    },
    getValueFromTable (header, rowIndex) {
      const otuIndex = this.tableValues.column_headers.findIndex(item => {
        return item === header
      })
      return this.tableValues.data[rowIndex][otuIndex]
    },
    sortBy (headerName) {
      const direction = this.headersOrder.findIndex(item => { return item === headerName })

      const index = this.tableValues.column_headers.findIndex(item => {
        return item === headerName
      })
      if (direction >= 0) {
        this.tableValues.data.sort(function (a, b) {
          if (a[index] > b[index]) {
            return 1
          }
          if (a[index] < b[index]) {
            return -1
          }
          return 0
        })
        this.headersOrder.splice(direction, 1)
      } else {
        this.tableValues.data.sort(function (a, b) {
          if (a[index] > b[index]) {
            return -1
          }
          if (a[index] < b[index]) {
            return 1
          }
          return 0
        })
        this.headersOrder.push(headerName)
      }
    }
  }
}
</script>
