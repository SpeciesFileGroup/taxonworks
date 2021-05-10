<template>
  <div>
    <spinner-component v-if="isLoading"/>
    <div
      class="grid-table"
      :style="columns">
      <div class="otu-cell"/>
      <div
        v-for="descriptor in descriptors"
        :key="descriptor.id">
        <div class="header-cell">
          <label class="header-label cursor-pointer">
            {{ descriptor.name }}
          </label>
        </div>
      </div>
      <template
        v-for="(row, rIndex) in rows">
        <div
          :key="rIndex"
          class="otu-cell padding-small">
          <a
            v-html="row.object.object_tag"
            :href="browseOtu(row.object.id)"/>
        </div>
        <div
          v-for="(rCol, cIndex) in row.depictions"
          class="image-cell padding-small"
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
                <img :src="depiction.image.alternatives.medium.image_file_url">
              </template>
            </tippy-component>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script>

import ajaxCall from 'helpers/ajaxCall'
import SpinnerComponent from 'components/spinner'
import { TippyComponent } from 'vue-tippy'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    SpinnerComponent,
    TippyComponent
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
      isLoading: false
    }
  },

  computed: {
    columns () {
      return { 'grid-template-columns': `200px repeat(${this.descriptors.length}, min-content)` }
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
