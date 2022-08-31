<template>
  <div class="full_width">
    <spinner-component
      v-if="sorting"
      :full-screen="true"
      legend="Loading..."/>
    <div 
      class="flex-separate"
      v-if="taxon">
      <div class="horizontal-left-content">
        <div class="header-box middle separate-right">
          <h3 v-if="taxon">Scoped: {{ taxon.name }}</h3>
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
      <div class="flex-separate">
        <span
          class="middle cursor-pointer"
          data-icon="reset"
          @click="resetList">Reset order</span>
        <csv-button
          class="separate-left"
          :list="tableRanks.data"
          :options="{ fields: csvFields }" />
      </div>
    </div>
    <table
      class="full_width"
      v-if="tableRanks">
      <thead>
        <tr>
          <template v-for="(header, index) in tableRanks.column_headers">
            <th 
              v-if="index >= renderPosition"
              @click="sortBy(header)">
              <span v-html="header.replace('_', '<br>')"/>
            </th>
          </template>
          <th @click="sortBy('cached')">Show</th>
        </tr>
      </thead>
      <tbody>
        <tr 
          v-for="(row, index) in tableRanks.data"
          class="contextMenuCells"
          :class="{ even: (index % 2)}">
          <template v-for="(header, hindex) in tableRanks.column_headers">
            <td v-if="hindex >= renderPosition">
              {{ row[hindex] }}
            </td>
          </template>
          <td>
            <a :href="getBrowseUrl(getValueFromTable('taxon_name_id', index))">{{ getValueFromTable('cached', index) }}</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import SpinnerComponent from 'components/spinner'
import CsvButton from 'components/csvButton'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    SpinnerComponent,
    CsvButton
  },
  props: {
    tableList: {
      type: Object,
      default: () => ({})
    }
  },
  computed: {
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    csvFields () {
      if (!Object.keys(this.tableRanks).length) return []
      return this.tableRanks.column_headers.map((item, index) => {
        return {
          label: item,
          value: (row, field) => row[index] || field.default,
          default: ''
        }
      })
    }
  },

  data () {
    return {
      renderPosition: 6,
      tableRanks: {},
      fieldset: [
        {
          label: 'Nomenclature stats',
          value: 'nomenclatureStates',
          set: ['valid_', 'invalid_']
        }
      ],
      selectedFieldSet: {
        label: 'Nomenclature stats',
        value: 'nomenclatureStates',
        set: ['valid_', 'invalid_']
      },
      ascending: false,
      sorting: false
    }
  },

  watch: {
    tableList: {
      handler (newVal) {
        this.sorting = true
        setTimeout(() => {
          this.tableRanks = newVal
          this.$nextTick(() => {
            this.sorting = false
          })
        }, 50)
      },
      deep: true
    }
  },

  methods: {
    getBrowseUrl (id) {
      return `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
    },

    resetList () {
      this.tableRanks = this.tableList
    },

    getValueFromTable (header, rowIndex) {
      const otuIndex = this.tableRanks.column_headers.findIndex(item => item === header)
      return this.tableRanks.data[rowIndex][otuIndex]
    },

    sortBy (headerName) {
      this.sorting = true
      setTimeout(() => {
        const index = this.tableRanks.column_headers.findIndex(item => item === headerName)

        this.tableRanks.data.sort((a, b) =>
          this.ascending
            ? (a[index] === null) - (b[index] === null) || +(a[index] > b[index]) || -(a[index] < b[index])
            : (a[index] === null) - (b[index] === null) || -(a[index] > b[index]) || +(a[index] < b[index])
        )
        this.ascending = !this.ascending

        this.$nextTick(() => {
          this.sorting = false
        })
      }, 50)
    }
  }
}
</script>
