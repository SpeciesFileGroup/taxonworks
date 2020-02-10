<template>
  <div>
    <table
      class="full_width"
      v-if="list.length">
      <thead>
        <tr>
          <th>Subject</th>
          <th>Properties</th>
          <th>Relationships</th>
          <th>Properties</th>
          <th>Object</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td v-html="item.subject.object_tag"></td>
          <td></td>
          <td v-html="item.biological_relationship.object_tag"></td>
          <td></td>
          <td v-html="item.object.object_tag"></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetBiologicalAssociations } from '../request/resource'

export default {
  props: {
    biologicalRelationship: {
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      list: []
    }
  },
  watch: {
    biologicalRelationship (newVal) {
      if(newVal) {
        GetBiologicalAssociations(newVal.id).then(response => {
          this.list = response.body
        })
      }
      else {
        this.list = []
      }
    }
  },
  methods: {

  }
}
</script>

<style>

</style>