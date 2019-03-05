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
          v-for="item in list"
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
    <table-list
      v-if="false"
      label="object_tag"
      :list="list"
      :edit="false"
      :destroy="false"
      :annotator="false"
      :attributes="['object_tag']"
      :header="['Object tag']"
      class="list"/>
  </div>
</template>
<script>

  import CRUD from '../request/crud.js'
  import AnnotatorExtend from './radialObjectExtend.js'
  import TableList from 'components/table_list.vue'

  export default {
    mixins: [CRUD, AnnotatorExtend],
    components: {
      TableList,
    },
    methods: {
      sendGlobalId(item) {
        console.log(item)
        this.$emit('onSelectedGlobalId', item.global_id)
      }
    }
  }
</script>
