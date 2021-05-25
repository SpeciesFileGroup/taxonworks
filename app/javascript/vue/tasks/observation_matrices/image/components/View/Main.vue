<template>
  <div>
    <spinner-component v-if="isLoading"/>
    <div class="horizontal-left-content margin-medium-bottom">
      <filter-rank v-model="filters.identified_to_rank" />
      <filter-language
        v-if="languages.length"
        v-model="filters.language_id"
        class="margin-small-left"
        :language-list="languages"
      />
    </div>
    <div>
      <button
        class="button normal-input button-default"
        @click="resetView">
        Unhide
      </button>
    </div>
    <table-grid
      :columns="columnsCount"
      :column-width="{
        default: 'min-content',
        0: '50px',
        1: '200px'
      }"
      gap="4">
      <div />
      <div />
      <cell-header
        v-show="!hideColumn.includes('otu') && existingOTUDepictions"
        v-model="hideColumn"
        title="OTU depictions"
        index="otu"
      />
      <template v-for="(descriptor, index) in observationColumns">
        <cell-header
          v-if="!hideColumn.includes(index)"
          v-model="hideColumn"
          :key="descriptor.id"
          :title="descriptor.name"
          :index="index"
        />
      </template>
      <template
        v-for="(row, rIndex) in observationRows">
        <template v-if="!hideRows.includes(rIndex)">
          <div
            class="observation-cell"
            :key="rIndex">
            <tippy-component
              animation="scale"
              placement="bottom"
              size="small"
              arrow-size="small"
              inertia
              arrow
              content="Hide">
              <template slot="trigger">
                <input
                  type="checkbox"
                  v-model="hideRows"
                  :value="rIndex">
              </template>
            </tippy-component>
          </div>
          <div
            :key="`${rIndex}-o`"
            class="otu-cell padding-small">
            <a
              v-html="row.object.object_tag"
              :href="browseLink(row.object)"/>
            <radial-object :global-id="row.object.global_id" />
          </div>

          <cell-depiction
            v-show="!hideColumn.includes('otu') && existingOTUDepictions"
            class="observation-cell padding-small"
            :key="`${rIndex}-d`"
            descriptor="OTU depictions"
            :object="row.object"
            :depictions="row.objectDepictions"
          />

          <template v-for="(rCol, cIndex) in row.depictions">
            <cell-depiction
              v-if="!hideColumn.includes(cIndex)"
              class="observation-cell padding-small"
              :key="`${rIndex} ${cIndex}`"
              :descriptor="observationColumns[cIndex].name"
              :object="row.object"
              :depictions="rCol"
            />
          </template>
        </template>
      </template>
    </table-grid>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import CellHeader from './CellHeader.vue'
import RadialObject from 'components/radials/object/radial'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import FilterLanguage from 'tasks/interactive_keys/components/Filters/Language'
import FilterRank from 'tasks/interactive_keys/components/Filters/IdentifierRank'
import CellDepiction from './CellDepiction.vue'
import { GetterNames } from '../../store/getters/getters'
import { TippyComponent } from 'vue-tippy'
import { RouteNames } from 'routes/routes'
import { Otu } from 'routes/endpoints'

const BROWSE_LINK = {
  CollectionObject: id => `${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`,
  Otu: id => `${RouteNames.BrowseOtu}?otu_id=${id}`,
  TaxonName: id => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
}

export default {
  components: {
    FilterLanguage,
    FilterRank,
    SpinnerComponent,
    TippyComponent,
    CellDepiction,
    CellHeader,
    RadialObject,
    TableGrid
  },
  props: {
    matrixId: {
      type: [Number, String],
      default: undefined
    },

    otusId: {
      type: [String, Array],
      default: () => []
    }
  },

  data () {
    return {
      hideColumn: [],
      hideRows: [],
      isLoading: false,
      languages: [],
      rows: [],
      showTable: false,
      filters: {
        language_id: undefined,
        identified_to_rank: undefined
      }
    }
  },

  computed: {
    columnsCount () {
      return this.observationColumns.length - this.hideColumn.length + this.staticColumns
    },

    staticColumns () {
      return this.existingOTUDepictions ? 3 : 2
    },

    observationColumns () {
      return this.$store.getters[GetterNames.GetObservationColumns]
    },

    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },

    observationRows () {
      return this.$store.getters[GetterNames.GetObservationRows]
    },

    observationLanguages () {
      return this.$store.getters[GetterNames.GetObservationLanguages]
    },

    existingOTUDepictions () {
      return this.observationRows.some(row => row.objectDepictions?.length)
    }
  },

  methods: {
    browseLink (object) {
      const objectClass = {
        otu_id: 'Otu',
        collection_object_id: 'CollectionObject',
        taxon_name_id: 'TaxonName'
      }

      const [property, klass] = Object.entries(objectClass).find(([key, value]) => object[key])

      return BROWSE_LINK[klass](object[property])
    },

    resetView () {
      this.hideRows = []
      this.hideColumn = []
    },

    loadOtuDepictions () {
      const promises = this.rows.map(item => Otu.depictions(item.object.id))

      Promise.all(promises).then(responses => {
        const rowDepictions = responses.map(({ body }) => body)

        if (rowDepictions.some(depictions => depictions.length)) {
          rowDepictions.forEach((depictions, index) => {
            this.rows[index].depictions.unshift(depictions)
          })
          this.descriptors.unshift({ name: 'OTU depictions' })
        }
      })
    }
  }
}
</script>
