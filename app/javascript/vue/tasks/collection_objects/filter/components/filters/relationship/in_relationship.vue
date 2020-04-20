<template>
  <div>
    <h2>In relationship</h2>
    <div class="separate-bottom">
      <ul class="no_bullets">
        <li
          v-for="(item, key) in biologicalRelationships"
          :key="key"
          v-if="!filterAlreadyPicked(item.id)">
          <label>
            <input
              :value="key"
              @click="addRelationship(item)"
              type="radio">
            {{item.inverted_name? `${item.name} / ${item.inverted_name}` : item.name }}
          </label>
        </li>
      </ul>
    </div>
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="item in relationshipSelected"
          :key="item.id">
          <span>{{item.inverted_name? `${item.name} / ${item.inverted_name}` : item.name }}</span>
          <span
            class="btn-delete button-circle"
            @click="removeItem(item)"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import { GetBiologicalRelationships } from '../../../request/resources.js'

export default {
  props: {
    value: {

    }
  },
  data() {
    return {
      lists: [],
      paramRelationships: undefined,
      biologicalRelationships: {},
      relationshipSelected: [],
      relationships: [],
      typeSelected: undefined
    }
  },
  watch: {
    value(newVal) {
      if(newVal.length || !this.relationshipSelected.length) return
      this.relationshipSelected = []
    },
    relationshipSelected(newVal) {
      this.$emit('input', newVal.map(relationship => { return relationship.id }))
    }
  },
  mounted() {
    GetBiologicalRelationships().then(response => {
      this.biologicalRelationships = response.body
    })
  },
  methods: {
    removeItem(relationship) {
      this.relationshipSelected.splice(this.relationshipSelected.findIndex(item => {
        return item.type == relationship.type
      }),1)
    },
    addRelationship(item) {
      this.relationshipSelected.push(item)
    },
    filterAlreadyPicked: function (id) {
      return this.relationshipSelected.find(function (item) {
        return (item.id == id)
      })
    }
  }
}
</script>