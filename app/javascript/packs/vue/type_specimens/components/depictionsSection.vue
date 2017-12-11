<template>
  <div class="panel type-specimen-box">
    <div class="header flex-separate middle">
        <h3>Depictions</h3>
        <expand v-model="displayBody"></expand>
    </div>
    <div class="body" v-if="displayBody">
      <div class="field">
          <dropzone class="dropzone-card separate-bottom" v-on:vdropzone-sending="sending" v-on:vdropzone-success="success" ref="figure" id="figure" url="/depictions" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone>
      </div>
    </div>
    </div>
  </div>
</template>

<script>

  import dropzone from '../../components/dropzone.vue';
  import expand from './expand.vue';
  
  export default {
    components: {
      dropzone,
      expand,
    },
    data: function() {
      return {
        displayBody: true,
        figuresList: [],
        dropzone: {
          paramName: "depiction[image_attributes][image_file]",
          url: "/depictions",
          headers: {
            'X-CSRF-Token' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
          },
          dictDefaultMessage: "Drop images here to add figures",
          acceptedFiles: "image/*"
        },
      }
    },
    methods: {
      'success': function(file, response) {
        this.figuresList.push(response);
        this.$refs.figure.removeFile(file);
      },
      'sending': function(file, xhr, formData) {
        //formData.append("depiction[annotated_global_entity]", decodeURIComponent(this.globalId));
      },
    }
  }
</script>