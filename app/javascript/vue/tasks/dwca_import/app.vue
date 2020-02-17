<!-- https://www.itsolutionstuff.com/post/file-upload-using-vue-js-axios-phpexample.html -->
<template>
  <div id="vue-task-dwca-import-new">
    <h1>DwC-A file upload</h1>
    <div
      v-if="dwcImport"
      class="overflow-scroll">
      <table-component
        :table="dwcImport.core_table"/>
    </div>
    <new-import v-else/>
  </div>
</template>
  
<script>

import NewImport from './components/NewImport'
import TableComponent from './components/table'
import { GetImport } from './request/resources'

  export default {
    components: {
      NewImport,
      TableComponent
    },
    data (){
      return {
        dwcImport: undefined
      }
    },
    mounted () {
      GetImport('test').then(response => {
        this.dwcImport = response.body
      })
    }
  }
</script>