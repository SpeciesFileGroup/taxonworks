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
            v-if="!isFiltered(header) || rankNames.includes(header)"
            v-for="(header, index) in tableRanks.column_headers">{{ header }}</th>
        </tr>
      </thead>
      <tbody>
        <tr 
          v-for="(row, index) in tableRanks.data">
          <template v-for="(header, hindex) in tableRanks.column_headers">
            <td v-if="!isFiltered(header) || rankNames.includes(header)">
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
    tableRanks: {
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
      rankNames: []
    }
  },
  watch: {
    rankList: {
      handler (newVal) {
        this.rankNames = [...new Set(this.getRankNames(newVal))]
      },
      deep: true
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
    }
  }
}
</script>
