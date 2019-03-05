<template>
  <div>
    <table-list
      label="object_tag"
      :list="list"
      :edit="false"
      :destroy="false"
      :attributes="['object_tag']"
      :header="['Object tag', 'Annotator']"
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
  }
</script>