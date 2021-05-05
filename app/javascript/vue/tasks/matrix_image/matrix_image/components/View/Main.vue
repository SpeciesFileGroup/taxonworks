<template>
  <div>
    <spinner-component v-if="isLoading"/>
    <table>
      <thead>
        <tr>
          <th class="object-cell"/>
          <th
            v-for="descriptor in descriptors"
            class="header-cell"
            :key="descriptor.id">
            <label class="header-label cursor-pointer">
              {{ descriptor.name }}
            </label>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          class="row-cell"
          v-for="(row, index) in rows">
          <td class="object-cell">
            <a
              v-html="row.object.object_tag"
              :href="browseOtu(row.object.id)"/>
          </td>
          <td
            v-for="rCol in row.depictions"
            class="padding-cell">
            <div
              v-for="depiction in rCol"
              :key="depiction.id">
              <img :src="depiction.image.alternatives.thumb.image_file_url">
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import ajaxCall from 'helpers/ajaxCall'
import SpinnerComponent from 'components/spinner'
import { RouteNames } from 'routes/routes'
import depiction from 'components/radials/object/images/depiction'

export default {
  components: {
    SpinnerComponent
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
