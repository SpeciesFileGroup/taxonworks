<template>
  <div>
    <h2>Properties</h2>
    <new-property
      @create="addProperty"
      @update="updateProperty"
      ref="property"/>
    <table class="full_width">
      <thead>
        <tr>
          <th>Name</th>
        </tr>
      </thead>
      <draggable
        v-model="list"
        tag="tbody"
        :group="{ name: 'property', pull: 'clone', put: false }"
        @start="drag=true"
        @end="drag=false">
        <tr
          v-for="item in list"
          :key="item.id">
          <td class="middle">
            <span
              @click="editProperty(item)"
              class="button button-circle btn-edit"/>
            <span
              class="margin-small-left"
              v-html="item.object_tag"/>
          </td>
        </tr>
      </draggable>
    </table>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import NewProperty from './NewProperty'
import { ControlledVocabularyTerm } from 'routes/endpoints'

export default {
  components: {
    Draggable,
    NewProperty
  },

  data () {
    return {
      list: [],
      drag: false
    }
  },

  mounted () {
    ControlledVocabularyTerm.where({ type: ['BiologicalProperty'] }).then(response => {
      this.list = response.body
    })
  },

  methods: {
    addProperty (property) {
      this.list.unshift(property)
    },

    updateProperty (property) {
      this.$set(this.list, this.list.findIndex(item => item.id === property.id), property)
    },

    editProperty (property) {
      this.$refs.property.setProperty(property)
    }
  }
}
</script>
