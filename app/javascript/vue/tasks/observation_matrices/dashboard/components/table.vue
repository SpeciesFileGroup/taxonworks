<template>
  <div class="full_width">
    <spinner-component
      v-if="sorting"
      :full-screen="true"
      legend="Loading..."
    />
    <div class="flex-separate margin-small-bottom">
      <div class="horizontal-left-content">
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
                v-for="(_, key) in fieldset"
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
      class="table-striped full_width"
      v-if="tableRanks"
    >
      <thead>
        <tr>
          <th class="w-2">
            <input
              type="checkbox"
              v-model="toggleSelection"
            />
          </th>
          <th>OTU name</th>
          <template
            v-for="header in fieldset[selectedFieldset]"
            :key="header"
          >
            <th
              v-if="list.column_headers.includes(header)"
              @click="sortBy(header)"
            >
              <span v-html="header.replace('_', '<br>')" />
            </th>
          </template>
          <th class="w-24">Code</th>
        </tr>
      </thead>
      <tbody>
        <template
          v-for="(row, index) in list.data"
          :key="row.taxon_name_id"
        >
          <tr
            class="contextMenuCells"
            :class="{ even: index % 2 }"
          >
            <td>
              <input
                :disabled="!row.otu_id"
                :value="row.otu_id"
                v-model="selectedIds"
                type="checkbox"
              />
            </td>
            <td v-html="otuLabel(row)" />
            <template
              v-for="header in fieldset[selectedFieldset]"
              :key="header"
            >
              <td v-if="list.column_headers.includes(header)">
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
import { RouteNames } from '@/routes/routes'
import ModalList from './modalList'
import SpinnerComponent from '@/components/ui/VSpinner'
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
    rankList() {
      return this.$store.getters[GetterNames.GetRanks]
    },

    taxon() {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    list() {
      const data = this.tableRanks.data?.map((row) =>
        Object.fromEntries(
          row.map((value, index) => [
            this.tableRanks.column_headers[index],
            value
          ])
        )
      )

      return {
        column_headers: this.tableRanks.column_headers || [],
        data
      }
    },

    toggleSelection: {
      get() {
        return (
          this.selectedIds.length ===
          this.list.data?.filter((r) => r.otu_id).length
        )
      },
      set(value) {
        if (value) {
          this.selectAll()
        } else {
          this.unselect()
        }
      }
    }
  },

  data() {
    return {
      renderFromPosition: 6,
      rankNames: [],
      tableRanks: {
        data: []
      },
      fieldset: {
        observations: [
          'descriptors_scored_for_otus',
          'otu_observation_count',
          'otu_observation_depictions'
        ]
      },
      selectedFieldset: 'observations',
      ascending: false,
      sorting: false,
      selectedIds: []
    }
  },

  watch: {
    rankList: {
      handler(newVal) {
        this.rankNames = [...new Set(this.getRankNames(newVal))]
      },
      deep: true
    },

    tableList: {
      handler(newVal) {
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
    getRankNames(list, nameList = []) {
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

    getValueFromTable(header, rowIndex) {
      const otuIndex = this.tableRanks.column_headers.findIndex(
        (item) => item === header
      )

      return this.tableRanks.data[rowIndex][otuIndex]
    },

    sortBy(headerName) {
      this.sorting = true
      setTimeout(() => {
        const index = this.tableRanks.column_headers.findIndex(
          (item) => item === headerName
        )

        this.tableRanks.data.sort((a, b) => {
          return this.ascending
            ? (a[index] === null) - (b[index] === null) ||
                +(a[index] > b[index]) ||
                -(a[index] < b[index])
            : (a[index] === null) - (b[index] === null) ||
                -(a[index] > b[index]) ||
                +(a[index] < b[index])
        })
        this.ascending = !this.ascending

        this.$nextTick(() => {
          this.sorting = false
        })
      }, 50)
    },

    unselect() {
      this.selectedIds = []
    },

    selectAll() {
      this.selectedIds = this.list.data
        .filter((column) => column.otu_id)
        .map((column) => column.otu_id)
    },

    openImageMatrix({ matrixId, otuIds }) {
      window.open(
        `${
          RouteNames.ImageMatrix
        }?observation_matrix_id=${matrixId}&edit=true&otu_filter=${otuIds.join(
          '|'
        )}`,
        '_blank'
      )
      this.showModal = false
    },

    getValidMark(isValid) {
      return isValid ? '✓' : '❌'
    },

    otuLabel(row) {
      return `
        <a href="/tasks/otus/browse?otu_id=${row.otu_id}">
          <span class="otu_tag">
            <span
              class="otu_tag_otu_name"
              title="${row.otu_id}">${row.otu_name || ''}
            </span> 
            <span
              class="otu_tag_taxon_name" 
              title="${row.taxon_name_id}"
            >
              <i>${row.cached}</i> ${row.cached_author_year || ''}
            </span> ${this.getValidMark(row.cached_is_valid)}
          </span>
        </a>`
    }
  }
}
</script>
