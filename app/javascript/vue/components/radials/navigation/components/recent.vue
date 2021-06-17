<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Object tag</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in list"
          class="contextMenuCells btn btn-neutral odd"
          :class="{ even: (index % 2 == 0)}"
          :key="item.id">
          <td class="cursor-pointer">
            <a
              href="#"
              v-html="item.object_tag"
              @click="sendGlobalId(item)"/>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import AnnotatorExtend from './radialObjectExtend.js'

export default {
  mixins: [CRUD, AnnotatorExtend],

  emits: ['onSelectedGlobalId'],

  methods: {
    sendGlobalId (item) {
      this.$emit('onSelectedGlobalId', item.global_id)
    }
  }
}
</script>
