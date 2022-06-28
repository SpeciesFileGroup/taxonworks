<template>
  <div class="full_width">
    <spinner-component
      v-if="sorting"
      :full-screen="true"
      legend="Loading..."
    />
    <div class="flex-separate margin-small-bottom">
      <div class="horizontal-left-content">
        <button
          class="button normal-input button-default margin-small-right"
          type="button"
          @click="selectAll"
        >
          Select all
        </button>
        <button
          class="button normal-input button-default margin-small-right"
          type="button"
          @click="unselect"
        >
          Unselect all
        </button>
        <add-to-matrix
          class="margin-small-right"
          :otu-ids="selectedIds"
        />
        <button-interactive-key
          class="margin-small-right"
          :otu-ids="selectedIds"
        />
        <button-edit-image-matrix
          class="margin-small-right"
          :otu-ids="selectedIds"
          @on-create="openImageMatrix"
        />
        <button-image-matrix :otu-ids="selectedIds" />
      </div>
      <ul class="no_bullets context-menu">
        <li>
          <label class="middle">
            <input
              v-model="withOtus"
              type="checkbox"
            >
            Show taxon names with OTUs only
          </label>
        </li>
        <li class="horizontal-left-content">
          <div class="header-box middle separate-right">
            <span v-if="taxon">Scoped: {{ taxon.name }}</span>
          </div>
          <div class="header-box middle separate-left">
            <select class="normal-input">
              <option
                v-for="field in fieldset"
                :key="field.value"
                :value="field.value"
              >
                {{ field.label }}
              </option>
            </select>
          </div>
        </li>
      </ul>
    </div>
    <table
      class="full_width"
      v-if="tableRanks"
    >
      <thead>
        <tr>
          <th>Selected</th>
          <th>otu id</th>
          <th>otu name</th>
          <template v-for="(header, index) in tableRanks.column_headers">
            <th
              v-if="renderFromPosition <= index"
              :key="header"
              @click="sortBy(header)"
            >
              <span v-html="header.replace('_', '<br>')" />
            </th>
          </template>
          <th>Code</th>
        </tr>
      </thead>
      <tbody>
        <template
          v-for="(row, index) in renderList.data"
          :key="row[1]"
        >
          <tr
            class="contextMenuCells"
            :class="{ even: (index % 2)}"
          >
            <td>
              <input
                :disabled="!row[4]"
                :value="row[4]"
                v-model="selectedIds"
                type="checkbox"
              >
            </td>
            <td>{{ row[4] }}</td>
            <td>
              <a
                v-if="row[5]"
                :href="`/otus/${row[4]}`"
              >
                {{ row[5] }}
              </a>
            </td>
            <template
              v-for="(header, hindex) in tableRanks.column_headers"
              :key="header"
            >
              <td v-if="renderFromPosition <= hindex">
                {{ row[hindex] }}
              </td>
            </template>
            <td>
              <modal-list
                :otu-id="getValueFromTable('otu_id', index)"
                :taxon-name-id="getValueFromTable('taxon_name_id', index)"
              />
            </td>
          </tr>
        </template>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { RouteNames } from 'routes/routes'
import ModalList from './modalList'
import SpinnerComponent from 'components/spinner'
import AddToMatrix from './addToMatrix'
import ButtonImageMatrix from './buttonImageMatrix.vue'
import ButtonEditImageMatrix from './ButtonEditImageMatrix.vue'
import ButtonInteractiveKey from './ButtonInteractiveKey.vue'

export default {
  components: {
    ModalList,
    SpinnerComponent,
    AddToMatrix,
    ButtonImageMatrix,
    ButtonEditImageMatrix,
    ButtonInteractiveKey
  },

  props: {
    tableList: {
      type: Object,
      default: () => ({})
    },

    filter: {
      type: Object,
      default: undefined
    }
  },

  computed: {
    rankList () {
      return this.$store.getters[GetterNames.GetRanks]
    },

    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    renderList () {
      return {
        column_headers: this.tableRanks.column_headers,
        data: this.withOtus
          ? this.tableRanks.data.filter(item => item[4])
          : this.tableRanks.data
      }
    }
  },

  data () {
    return {
      renderFromPosition: 6,
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
      sorting: false,
      withOtus: false,
      selectedIds: []
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
        this.selectedIds = []
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
    getRankNames (list, nameList = []) {
      for (const key in list) {
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

    getValueFromTable (header, rowIndex) {
      const otuIndex = this.tableRanks.column_headers.findIndex(item => item === header)

      return this.tableRanks.data[rowIndex][otuIndex]
    },

    sortBy (headerName) {
      this.sorting = true
      setTimeout(() => {
        const index = this.tableRanks.column_headers.findIndex(item => item === headerName)

        this.tableRanks.data.sort(function (a, b) {
          return this.ascending
            ? (a[index] === null) - (b[index] === null) || +(a[index] > b[index]) || -(a[index] < b[index])
            : (a[index] === null) - (b[index] === null) || -(a[index] > b[index]) || +(a[index] < b[index])
        })
        this.ascending = !this.ascending

        this.$nextTick(() => {
          this.sorting = false
        })
      }, 50)
    },

    unselect () {
      this.selectedIds = []
    },

    selectAll () {
      this.selectedIds = this.tableList.data.filter(column => column[4]).map(column => column[4])
    },

    openImageMatrix ({ matrixId, otuIds }) {
      window.open(`${RouteNames.ImageMatrix}?observation_matrix_id=${matrixId}&otu_filter=${otuIds.join('|')}`, '_blank')
      this.showModal = false
    }
  }
}
</script>
