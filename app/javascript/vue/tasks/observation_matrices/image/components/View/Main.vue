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
      <template v-for="(descriptor, index) in descriptors">
        <div
          v-if="!hideColumn.includes(index)"
          :key="descriptor.id">
          <div class="header-cell">
            <label
              class="header-label cursor-pointer ellipsis"
              :title="descriptor.name">
              <input
                type="checkbox"
                :value="index"
                v-model="hideColumn">
              {{ descriptor.name }}
            </label>
          </div>
        </div>
      </template>
      <template
        v-for="(row, rIndex) in rows">
        <template v-if="!hideRows.includes(rIndex)">
          <div
            class="observation-cell"
            :key="rIndex">
            <input
              type="checkbox"
              v-model="hideRows"
              :value="rIndex">
          </div>
          <div
            :key="`${rIndex}-o`"
            class="otu-cell padding-small">
            <a
              v-html="row.object.object_tag"
              :href="browseLink(row.object)"/>
            <radial-object :global-id="row.object.global_id" />
          </div>

          <template v-for="(rCol, cIndex) in row.depictions">
            <div
              class="observation-cell padding-small"
              v-if="!hideColumn.includes(cIndex)"
              :key="`${rIndex} ${cIndex}`">
              <div
                v-for="depiction in rCol"
                :key="depiction.id">
                <template v-if="depiction.image">
                  <tippy-component
                    animation="scale"
                    placement="bottom"
                    size="small"
                    arrow-size="small"
                    inertia
                    arrow
                    :trigger="depiction.image.citations.length
                      ? 'mouseenter focus'
                      : 'manual'"
                    :content="depiction.image.citations.map(citation => citation.citation_source_body).join('; ')">
                    <template slot="trigger">
                      <image-viewer
                        :depiction="depiction"
                      >
                        <img :src="depiction.image.alternatives.medium.image_file_url">
                        <div
                          class="panel content full_width margin-small-right"
                          slot="infoColumn">
                          <h3>Image matrix</h3>
                          <ul class="no_bullets">
                            <li>Column: <b>{{ descriptors[cIndex].name }}</b></li>
                            <li>Row: <a
                              v-html="row.object.object_tag"
                              :href="browseLink(row.object)"/>
                            </li>
                          </ul>
                        </div>
                      </image-viewer>
                    </template>
                  </tippy-component>
                </template>
              </div>
            </div>
          </template>
        </template>
      </template>
    </table-grid>
  </div>
</template>

<script>

import ajaxCall from 'helpers/ajaxCall'
import composeImage from '../../helpers/composeImage'
import SpinnerComponent from 'components/spinner'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import RadialObject from 'components/radials/object/radial'
import TableGrid from 'components/layout/Table/TableGrid.vue'
import FilterLanguage from 'tasks/interactive_keys/components/Filters/Language'
import FilterRank from 'tasks/interactive_keys/components/Filters/IdentifierRank'
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
    ImageViewer,
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
      descriptors: [],
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
      return this.descriptors.length - this.hideColumn.length + 2
    }
  },

  watch: {
    filters: {
      handler () {
        this.loadMatrix()
      },
      deep: true
    }
  },

  created () {
    this.loadMatrix()
  },

  methods: {
    browseLink (object) {
      return BROWSE_LINK[object.base_class](object.id)
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
    },

    loadMatrix () {
      const retrieveDepictions = this.otusId.length
        ? ajaxCall('get', '/tasks/observation_matrices/image_matrix/0/key', { params: { otu_filter: this.otusId, ...this.filters } })
        : ajaxCall('get', `/tasks/observation_matrices/image_matrix/${this.matrixId}/key`, { params: this.filters })

      this.isLoading = true
      retrieveDepictions.then(({ body }) => {
        this.languages = body.descriptor_available_languages || []
        this.descriptors = body.list_of_descriptors
        this.rows = Object.values(body.depiction_matrix)
          .filter(row => [].concat(...row.depictions).length)
          .map(observation => ({
            ...observation,
            depictions: observation.depictions
              .map(obsDepictions => obsDepictions
                .filter(depiction => depiction.depiction_object_type === 'Observation')
                .map(depiction => ({
                  ...depiction,
                  image: composeImage(depiction.image_id, body.image_hash[depiction.image_id])
                })))
          }))
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
