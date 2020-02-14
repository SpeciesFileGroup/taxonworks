<!-- https://www.itsolutionstuff.com/post/file-upload-using-vue-js-axios-phpexample.html -->
<template>
  <div id="vue-task-dwca-import-new">
    <h1>DwC-A file upload</h1>
    <new-import/>
  </div>
</template>
  
<script>

import NewImport from './components/NewImport'

  export default {
    components: {
      NewImport
    },
    data (){
      return {
        file: ''
      }
    },
    mounted () {

    }
  }
</script>