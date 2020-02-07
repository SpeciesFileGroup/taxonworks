<template>
  <div>
    <h2>Relationships</h2>
    <new-relationship @create="addProperty"/>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Inverted name</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
          @click="$emit('selected', item)">
          <td>{{ item.name }}</td>
          <td>{{ item.inverted_name }}</td>
          <td></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetBiologicalRelationships } from '../../request/resource'
import NewRelationship from './NewRelationship'

export default {
  components: {
    NewRelationship
  },
  data () {
    return {
      list: []
    }
  },
  mounted () {
    GetBiologicalRelationships().then(response => {
      this.list = response.body
    })
  },
  methods: {
    addProperty (property) {
      this.list.unshift(property)
    }
  }
}
</script>

<style>

</style>