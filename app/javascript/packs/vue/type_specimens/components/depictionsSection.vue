<template>
  <div class="panel type-specimen-box">
    <spinner :show-spinner="false" :show-legend="false" v-if="!getTypeMaterial.id"></spinner>
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

  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';

  import dropzone from '../../components/dropzone.vue';
  import expand from './expand.vue';
  import spinner from '../../components/spinner.vue';
  
  export default {
    components: {
      dropzone,
      expand,
      spinner
    },
    computed: {
      getTypeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      }
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