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
            <span class="display-block">{{ item.name }}</span>
            <span
              v-if="item.definition"
              class="margin-small-left subtle">
              {{ item.definition }}
            </span>
          </td>
          <td>{{ item.inverted_name }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import { BiologicalRelationship } from 'routes/endpoints'
import NewRelationship from './NewRelationship'

export default {
  components: {
    NewRelationship
  },

  emits: ['selected'],

  data () {
    return {
      list: []
    }
  },

  created () {
    BiologicalRelationship.all().then(response => {
      const urlParams = new URLSearchParams(window.location.search)
      const relationshipIdParam = Number(urlParams.get('biological_relationship_id'))

      this.list = response.body

      if (/^\d+$/.test(relationshipIdParam)) {
        const relationship = this.list.find(item => item.id === relationshipIdParam)
        if (relationship) {
          this.$emit('selected', relationship)
        }
      }
    })
  },

  methods: {
    addRelationship (relationship) {
      const index = this.list.findIndex(item => item.id === relationship.id)

      if (index > -1) {
        this.list[index] = relationship
      } else {
        this.list.unshift(relationship)
      }
      this.$emit('selected', relationship)
    }
  }
}
</script>
