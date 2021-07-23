<template>
  <div>
    <h2>Similar objects</h2>
    <ul class="no_bullets">
      <li 
        v-for="item in similarObjects"
        :key="item.observation_matrix_row_id">
        <span>({{ item.similarities }})</span>
        <span v-html="item.otu_label || item.collection_object_label"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { sortArray } from 'helpers/arrays'

export default {
  computed: {
    rowId () {
      return this.$store.getters[GetterNames.GetMatrixRow].id
    },

    similarObjects () {
      const objects = this.$store.getters[GetterNames.GetDescription]?.similar_objects || []
      const orderSimilars = sortArray(objects, 'similarities', false)

      return objects.length
        ? orderSimilars.filter(item => item.similarities === orderSimilars[0].similarities)
        : []
    }

  }
}
</script>
