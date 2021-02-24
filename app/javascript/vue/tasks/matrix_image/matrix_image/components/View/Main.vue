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
          <td
            class="object-cell"
            v-html="row.object.object_tag"/>
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

export default {
  components: {
    SpinnerComponent
  },
  props: {
    matrixId: {
      type: [Number, String],
      required: true
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
    ajaxCall('get', `/tasks/observation_matrices/image_matrix/${this.matrixId}/key`).then(({ body }) => {
      this.descriptors = Object.values(body.list_of_descriptors)
      this.rows = Object.values(body.depiction_matrix).filter(row => [].concat(...row.depictions).length)
      this.isLoading = false
    }).then(() => {
      this.isLoading = false
    })
  }
}
</script>

<style>

</style>
