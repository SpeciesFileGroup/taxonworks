<template>
  <div>
    <spinner-component v-if="isLoading"/>
    <div>
      <button
        class="button normal-input button-default"
        @click="resetView">
        Unhide
      </button>
    </div>
    <div
      class="grid-table"
      :style="columns">
      <div />
      <div />
      <template v-for="(descriptor, index) in descriptors">
        <div
          v-if="!hideColumn.includes(index)"
          :key="descriptor.id">
          <div class="header-cell">
            <label class="header-label cursor-pointer">
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
            class="image-cell"
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
              :href="browseOtu(row.object.id)"/>
            <radial-object :global-id="row.object.global_id" />
          </div>
          <template v-for="(rCol, cIndex) in row.depictions">
            <div
              class="image-cell padding-small"
              v-if="!hideColumn.includes(cIndex)"
              :key="`${rIndex} ${cIndex}`">
              <div
                v-for="depiction in rCol"
                :key="depiction.id">
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
                            :href="browseOtu(row.object.id)"/>
                          </li>
                        </ul>
                      </div>
                    </image-viewer>
                  </template>
                </tippy-component>
              </div>
            </div>
          </template>
        </template>
      </template>
    </div>
  </div>
</template>

<script>

import ajaxCall from 'helpers/ajaxCall'
import SpinnerComponent from 'components/spinner'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import RadialObject from 'components/radials/object/radial'
import { TippyComponent } from 'vue-tippy'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    SpinnerComponent,
    TippyComponent,
    ImageViewer,
    RadialObject
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
      rows: [],
      showTable: false,
      isLoading: false,
      hideRows: [],
      hideColumn: []
    }
  },

  computed: {
    columns () {
      return { 'grid-template-columns': `50px 200px ${this.repeatColumn}` }
    },

    repeatColumn () {
      return this.descriptors.length !== this.hideColumn.length
        ? `repeat(${this.descriptors.length - this.hideColumn.length}, min-content)`
        : ''
    }
  },

  created () {
    this.isLoading = true
    const retrieveDepictions = this.otusId.length
      ? ajaxCall('get', '/tasks/observation_matrices/image_matrix/0/key', { params: { otu_filter: this.otusId } })
      : ajaxCall('get', `/tasks/observation_matrices/image_matrix/${this.matrixId}/key`)

    retrieveDepictions.then(({ body }) => {
      this.descriptors = Object.values(body.list_of_descriptors)
      this.rows = Object.values(body.depiction_matrix)
        .filter(row => [].concat(...row.depictions).length)
        .map(observation => ({
          ...observation,
          depictions: observation.depictions.map(obsDepictions => obsDepictions.filter(depiction => depiction.depiction_object_type === 'Observation'))
        }))
    }).finally(() => {
      this.isLoading = false
    })
  },

  methods: {
    browseOtu (id) {
      return `${RouteNames.BrowseOtu}?otu_id=${id}`
    },
    resetView () {
      this.hideRows = []
      this.hideColumn = []
    }
  }
}
</script>
<style lang="scss" scoped>
  .grid-table {
    display: grid;
    gap: 4px;

    .image-cell {
      display: flex;
      align-items: center;
      justify-content: center;
      flex-direction: column;
      background-color: white;
    }

    .otu-cell {
      display: flex;
      align-items: center;
      justify-content: left;
      background-color: white;
    }
  }
</style>
