<template>
  <div id="vue_type_specimens">
    <spinner :full-screen="true" legend="Loading..." :logo-size="{ width: '100px', height: '100px'}" v-if="loading"></spinner>
    <h1>New type specimen</h1>
    <name-section class="separate-bottom"></name-section>
    <type-material-section class="separate-top separate-bottom"></type-material-section>
    <metadata-section class="separate-top separate-bottom"></metadata-section>
    <depictions-section class="separate-top separate-bottom"></depictions-section>
  </div>
</template>

<script>

  import nameSection from './components/nameSection.vue';
  import typeMaterialSection from './components/typeMaterial.vue';
  import depictionsSection from './components/depictionsSection.vue';
  import metadataSection from './components/metadataSection.vue';
  import spinner from '../components/spinner.vue';

  export default {
    components: {
      nameSection,
      typeMaterialSection,
      depictionsSection,
      metadataSection,
      spinner
    },
    data: function() {
      return {
        loading: false,
      }
    },
  }

</script>
<style lang="scss">
  #vue_type_specimens {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    input[type="text"], textarea {
      width: 300px;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
    .type-specimen-box {

      transition: all 1s;

      label {
        display: block;
      }

      height: 100%;
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
      .header {
        border-left:4px solid green;
        h3 {
        font-weight: 300;
      }
      padding: 1em;
      padding-left: 1.5em;
      border-bottom: 1px solid #f5f5f5;
      }
      .body {
        padding: 2em;
        padding-top: 1em;
        padding-bottom: 1em;
      }
      .vue-autocomplete-input {
        width: 300px;
      }
      .taxonName-input,#error_explanation {
        width: 300px;
      }
    }
  }

</style>