<template>
  <div class="full_width">
    <div class="header-box middle">
      <span v-if="taxon">Scoped: {{ taxon.name }}</span>
    </div>
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
      class="full_width"
      v-if="tableRanks">
      <thead>
        <tr>
          <th 
            v-if="!isFiltered(header) || selectedFieldSet.set.includes(header) || ranksSelected.includes(header)"
            v-for="(header, index) in tableRanks.column_headers"
            @click="sortBy(header)">
            <span v-html="header.replace('_', '<br>')"/>
          </th>
          <th>Code</th>
        </tr>
      </thead>
      <tbody>
        <tr 
          v-for="(row, index) in tableRanks.data">
          <template v-for="(header, hindex) in tableRanks.column_headers">
            <td v-if="!isFiltered(header) || selectedFieldSet.set.includes(header) || ranksSelected.includes(header)">
              {{ row[hindex] }}
            </td>
          </template>
          <td>
            <modal-list
              :otu-id="getValueFromTable('otu_id', index)"
              :taxon-id="getValueFromTable('taxon_name_id', index)"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import ModalList from './modalList'
import { GetterNames } from '../store/getters/getters'

export default {
  components: {
    ModalList
  },
  props: {
    tableList: {
      type: Object,
      default: () => { return {} }
    },
    ranksSelected: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    rankList () {
      return this.$store.getters[GetterNames.GetRanks]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  data () {
    return {
      show: ['cached'],
      rankNames: [],
      tableRanks: {},
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
    rankList: {
      handler (newVal) {
        this.rankNames = [...new Set(this.getRankNames(newVal))]
      },
      deep: true
    },
    tableList: {
      handler (newVal) {
        this.tableRanks = this.orderRanksTable(newVal)
      }
    }
  },
  methods: {
    isFiltered (value) {
      return !this.show.includes(value)
    },
    getRankNames (list, nameList = []) {
      for (var key in list) {
        if (typeof list[key] === 'object') {
          this.getRankNames(list[key], nameList)
        } else {
          if (key === 'name') {
            nameList.push(list[key])
          }
        }
      }
      return nameList
    },
    orderRanksTable (list) {
      let newDataList = []
      let ranksOrder = this.rankNames.filter(rank => {
        return list.column_headers.includes(rank)
      })

      ranksOrder = ranksOrder.concat(list.column_headers.filter(item => {
        return !ranksOrder.includes(item)
      }))

      ranksOrder.forEach((rank, index) => {
        const indexHeader = list.column_headers.findIndex(item => { return item === rank })
        if (indexHeader >= 0) {
          list.data.forEach((row, rIndex) => {
            newDataList[rIndex] ? newDataList[rIndex].push(row[indexHeader]) : newDataList[rIndex] = [row[indexHeader]]
          })
        }
      })
      return { column_headers: ranksOrder, data: newDataList }
    },
    getValueFromTable (header, rowIndex) {
      const otuIndex = this.tableRanks.column_headers.findIndex(item => {
        return item === header
      })
      return this.tableRanks.data[rowIndex][otuIndex]
    },
    sortBy (headerName) {
      const direction = this.headersOrder.findIndex(item => { return item === headerName })

      const index = this.tableRanks.column_headers.findIndex(item => {
        return item === headerName
      })
      if (direction >= 0) {
        this.tableRanks.data.sort(function (a, b) {
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
        this.tableRanks.data.sort(function (a, b) {
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
