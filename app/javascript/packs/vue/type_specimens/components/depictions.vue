<template>
  <div class="depiction-container">
    <spinner v-if="!getTypeMaterial.id" :show-spinner="false" legend="Create a type specimen to upload images"></spinner>
    <dropzone class="dropzone-card separate-bottom" v-on:vdropzone-sending="sending" v-on:vdropzone-success="success" ref="figure" id="figure" url="/depictions" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone>
    <div class="flex-wrap-row" v-if="figuresList.length">
      <depictionImage v-for="item in figuresList" 
        :thumb="item.image.result.alternatives.thumb"
        :medium="item.image.result.alternatives.medium">
      </depictionImage>
    </div>
  </div>

</template>

<script>

  import { GetterNames } from '../store/getters/getters';
  import { MutationNames } from '../store/mutations/mutations';
  import { GetDepictions } from '../request/resources';

  import dropzone from '../../components/dropzone.vue';
  import expand from './expand.vue';
  import spinner from '../../components/spinner.vue';
  import depictionImage from './depictionImage.vue';
  
  export default {
    components: {
      depictionImage,
      dropzone,
      expand,
      spinner
    },
    computed: {
      getTypeMaterial() {
        return this.$store.getters[GetterNames.GetTypeMaterial]
      },
      getImages() {
        return this.$store.getters[GetterNames.GetTypeMaterial].collection_object.images
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
    watch: {
      getTypeMaterial(newVal, oldVal) {
        if(newVal.id && (newVal.id != oldVal.id)) {
          GetDepictions(newVal.collection_object.id).then(response => {
            console.log(response);
            this.figuresList = response;
          })
        }
      }
    },
    methods: {
      'success': function(file, response) {
        this.figuresList.push(response);
        this.$refs.figure.removeFile(file);
      },
      'sending': function(file, xhr, formData) {
        formData.append("depiction[depiction_object_id]", this.getTypeMaterial.collection_object.id);
        formData.append("depiction[depiction_object_type]", 'CollectionObject');
      },
    }
  }
</script>
<style scoped>
  .depiction-container {
    width: 500px;
    max-width: 500px;
  }
</style>