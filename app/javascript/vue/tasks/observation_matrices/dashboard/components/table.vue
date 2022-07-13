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
            <select
              v-model="selectedFieldset"
              class="normal-input"
            >
              <option
                v-for="(field, key) in fieldset"
                :key="key"
                :value="key"
              >
                {{ key }}
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
          <th>OTU name</th>
          <template
            v-for="header in fieldset[selectedFieldset]"
            :key="header"
          >
            <th
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
          :key="row.taxon_name_id"
        >
          <tr
            class="contextMenuCells"
            :class="{ even: (index % 2)}"
          >
            <td>
              <input
                :disabled="!row.otu_id"
                :value="row.otu_id"
                v-model="selectedIds"
                type="checkbox"
              >
            </td>
            <td v-html="otuLabel(row)" />
            <template
              v-for="(header) in fieldset[selectedFieldset]"
              :key="header"
            >
              <td>
                {{ row[header] }}
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
      const data = (this.withOtus
        ? this.tableRanks.data.filter(item => item[4])
        : this.tableRanks.data
      ).map(row => Object.fromEntries(
        row.map((value, index) => [this.tableRanks.column_headers[index], value])
      ))

      return {
        column_headers: this.tableRanks.column_headers,
        data
      }
    }
  },

  data () {
    return {
      renderFromPosition: 6,
      rankNames: [],
      tableRanks: {
        data: []
      },
      fieldset: {
        observations: ['descriptors_scored_for_otus', 'otu_observation_count', 'otu_observation_depictions']
      },
      selectedFieldset: 'observations',
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

        this.tableRanks.data.sort((a, b) => {
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
      this.selectedIds = this.renderList.data.filter(column => column.otu_id).map(column => column.otu_id)
    },

    openImageMatrix ({ matrixId, otuIds }) {
      window.open(`${RouteNames.ImageMatrix}?observation_matrix_id=${matrixId}&otu_filter=${otuIds.join('|')}`, '_blank')
      this.showModal = false
    },

    getValidMark (isValid) {
      return isValid
        ? '✓'
        : '❌'
    },

    otuLabel (row) {
      return `
        <a href="${row.otu_id}">
          <span class="otu_tag">
            <span
              class="otu_tag_otu_name"
              title="${row.otu_id}">${row.otu_name || ''}
            </span> 
            <span
              class="otu_tag_taxon_name" 
              title="${row.taxon_name_id}"
            >
              <i>${row.cached}</i> ${row.cached_author_year}
            </span> ${this.getValidMark(row.cached_is_valid)}
          </span>
        </a>`
    }
  }
}
</script>
