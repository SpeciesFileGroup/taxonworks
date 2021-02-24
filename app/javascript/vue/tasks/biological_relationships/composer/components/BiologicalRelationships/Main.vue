<template>
  <div>
    <h2>Relationships</h2>
    <new-relationship @create="addRelationship"/>
    <table class="full_width">
      <thead>
        <tr>
          <th>Name</th>
          <th>Inverted name</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
          @click="$emit('selected', item)">
          <td>
            <span>{{ item.name }}</span><br>
            <span class="margin-small-left subtle">{{item.definition }}</span>
          </td>
          <td>{{ item.inverted_name }}</td>
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
      const urlParams = new URLSearchParams(window.location.search)
      const relationshipIdParam = Number(urlParams.get('biological_relationship_id'))

      if (/^\d+$/.test(relationshipIdParam)) {
        const relationship = this.list.find(item => { return item.id === relationshipIdParam })
        if (relationship) {
          this.$emit('selected', relationship)
        }
      }
    })
  },
  methods: {
    addRelationship (relationship) {
      let index = this.list.findIndex(item => { return item.id === relationship.id })
      if (index > -1) {
        this.$set(this.list, index, relationship)
      } else {
        this.list.unshift(relationship)
      }
      this.$emit('selected', relationship)
    }
  }
}
</script>

<style>

</style>