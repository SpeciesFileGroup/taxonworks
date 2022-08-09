<template>
  <div>
    <h2>Properties</h2>
    <new-property
      @save="addProperty"
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
        item-key="id"
        @start="drag=true"
        @end="drag=false">
        <template #item="{ element }">
          <tr>
            <td>
              <div class="middle">
                <span
                  @click="editProperty(element)"
                  class="button button-circle btn-edit"/>
                <span
                  class="margin-small-left"
                  v-html="element.object_tag"/>
              </div>
            </td>
          </tr>
        </template>
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
      const index = this.list.findIndex(item => item.id === property.id)

      if (index > -1) {
        this.list[index] = property
      } else {
        this.list.unshift(property)
      }
    },

    updateProperty (property) {
      this.list[this.list.findIndex(item => item.id === property.id)] = property
    },

    editProperty (property) {
      this.$refs.property.setProperty(property)
    }
  }
}
</script>
