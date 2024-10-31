<template>
  <div>
    <h2>Relationships</h2>
    <new-relationship @create="addRelationship" />
    <table class="table-striped">
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
          @click="$emit('selected', item)"
        >
          <td class="cursor-pointer">
            <span class="display-block">{{ item.name }}</span>
            <div
              v-if="item.definition"
              class="subtle ellipsis definition-size"
              :title="item.definition"
            >
              {{ item.definition }}
            </div>
          </td>
          <td>{{ item.inverted_name }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { BiologicalRelationship } from '@/routes/endpoints'
import { extend } from '../constants/extend.js'
import NewRelationship from './NewRelationship'

export default {
  components: {
    NewRelationship
  },

  emits: ['selected'],

  data() {
    return {
      list: []
    }
  },

  created() {
    BiologicalRelationship.where({ extend }).then((response) => {
      const urlParams = new URLSearchParams(window.location.search)
      const relationshipIdParam = Number(
        urlParams.get('biological_relationship_id')
      )

      this.list = response.body

      if (/^\d+$/.test(relationshipIdParam)) {
        const relationship = this.list.find(
          (item) => item.id === relationshipIdParam
        )
        if (relationship) {
          this.$emit('selected', relationship)
        }
      }
    })
  },

  methods: {
    addRelationship(relationship) {
      const index = this.list.findIndex((item) => item.id === relationship.id)

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

<style scoped>
.definition-size {
  width: 300px;
  max-width: 300px;
}
</style>
