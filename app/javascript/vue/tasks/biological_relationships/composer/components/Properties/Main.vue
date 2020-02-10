<template>
  <div>
    <h2>Properties</h2>
    <new-property @create="addProperty"/>
    <table class="full_width">
      <thead>
        <tr>
          <th>Name</th>
          <th></th>
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
          <td>{{ item.name }}</td>
          <td></td>
        </tr>
      </draggable>
    </table>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import { GetProperties } from '../../request/resource'
import NewProperty from './NewProperty'

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
    GetProperties().then(response => {
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
