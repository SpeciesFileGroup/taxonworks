<template>
  <div>
    <div class="header-box middle">
      <span v-if="taxon">Scoped: {{ taxon.name }}</span>
    </div>
    <table
      v-if="tableRanks">
      <thead>
        <tr>
          <th 
            v-for="(header, index) in tableRanks.column_headers">{{ header }}</th>
        </tr>
      </thead>
      <tbody>
        <tr 
          v-for="(row, index) in tableRanks.data">
          <template v-for="(header, hindex) in tableRanks.column_headers">
            <td>
              {{ row[hindex] }}
            </td>
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'

export default {
  props: {
    tableList: {
      type: Object,
      default: () => { return {} }
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
      tableRanks: {}
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
        console.log(this.orderRanksTable(newVal))
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
      ranksOrder = ranksOrder.concat(this.show)
      console.log(ranksOrder)

      ranksOrder.forEach((rank, index) => {
        const indexHeader = list.column_headers.findIndex(item => { return item === rank })
        if (indexHeader >= 0) {
          list.data.forEach((row, rIndex) => {
            newDataList[rIndex] ? newDataList[rIndex].push(row[indexHeader]) : newDataList[rIndex] = [row[indexHeader]]
          })
        }
      })
      return { column_headers: ranksOrder, data: newDataList }
    }
  }
}
</script>
