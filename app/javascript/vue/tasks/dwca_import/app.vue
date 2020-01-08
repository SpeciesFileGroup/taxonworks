<!-- https://www.itsolutionstuff.com/post/file-upload-using-vue-js-axios-phpexample.html -->
<template>
  <div id="vue-task-dwca-import-new">
    <h1>DwC-A file upload</h1>
    <label>File
      <input type="file" id="file" ref="file" v-on:change="onChangeFileUpload()"/>
    </label>
      <button v-on:click="submitForm()">Upload</button>
  </div>
</template>
  
<script>
  export default {
    data(){
      return {
        file: ''
      }
    },
  
    methods: {
      submitForm(){
            let formData = new FormData();
            formData.append('file', this.file);
  
            this.$http.post('upload',
                formData,
                {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
              }
            ).then(function(data){
              console.log(data.data);
            })
            .catch(function(){
              console.log('FAILURE!!');
            });
      },
  
      onChangeFileUpload(){
        this.file = this.$refs.file.files[0];
      }
    }
  }
</script>