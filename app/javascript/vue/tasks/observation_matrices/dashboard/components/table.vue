<template>
  <div class="full_width">
    <spinner-component
      v-if="sorting"
      :full-screen="true"
      legend="Loading..."/>
    <div class="flex-separate">
      <div class="horizontal-left-content">
        <div class="header-box middle separate-right">
          <span v-if="taxon">Scoped: {{ taxon.name }}</span>
        </div>
        <div class="header-box middle separate-left">
          <select class="normal-input">
            <option
              v-for="field in fieldset"
              :key="field.value"
              :value="field.value">
              {{ field.label }}
            </option>
          </select>
        </div>
      </div>
      <span
        class="middle cursor-pointer"
        data-icon="reset"
        @click="resetList">Reset order</span>
    </div>
    <table
      class="full_width"
      v-if="tableRanks">
      <thead>
        <tr>
          <th 
            v-if="renderFromPosition <= index"
            v-for="(header, index) in tableRanks.column_headers"
            @click="sortBy(header)">
            <span v-html="header.replace('_', '<br>')"/>
          </th>
          <th>Code</th>
        </tr>
      </thead>
      <tbody>
        <tr 
          v-for="(row, index) in tableRanks.data"
          class="contextMenuCells btn btn-neutral"
          :class="{ even: (index % 2)}">
          <template v-for="(header, hindex) in tableRanks.column_headers">
            <td v-if="renderFromPosition <= hindex">
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
import SpinnerComponent from 'components/spinner'
import { setTimeout } from 'timers';

export default {
  components: {
    ModalList,
    SpinnerComponent
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
      renderFromPosition: 4,
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
      ascending: false,
      sorting: false
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
        this.sorting = true
        setTimeout(() => {
          this.tableRanks = this.tableList
          this.$nextTick(() => {
            this.sorting = false
          })
        }, 50)
      }
    }
  },
  methods: {
    isFiltered (header) {
      return this.show.includes(header) || this.selectedFieldSet.set.includes(header) || this.ranksSelected.includes(header)
    },
    resetList() {
      this.tableRanks = this.orderRanksTable(this.tableList)
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
      this.sorting = true
      setTimeout(() => {
        const index = this.tableRanks.column_headers.findIndex(item => {
          return item === headerName
        })
        if (this.ascending) {
          this.tableRanks.data.sort(function (a, b) {
            return (a[index] === null) - (b[index] === null) || +(a[index] > b[index]) || -(a[index] < b[index])
          })
          this.ascending = false
        } else {
          this.tableRanks.data.sort(function (a, b) {
            return (a[index] === null) - (b[index] === null) || -(a[index] > b[index]) || +(a[index] < b[index])
          })
          this.ascending = true
        }
        this.$nextTick(() => {
          this.sorting = false
        })
      }, 50)
    }
  }
}
</script>
