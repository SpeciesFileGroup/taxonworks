<template>
  <div id="vue_type_specimens">
    <spinner :full-screen="true" legend="Loading..." :logo-size="{ width: '100px', height: '100px'}" v-if="settings.loading"></spinner>
    <h1>New type specimen</h1>
    <div>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <name-section class="separate-bottom"></name-section>
          <type-material-section class="separate-top separate-bottom"></type-material-section>
          <metadata-section class="separate-top separate-bottom"></metadata-section>
          <depictions-section class="separate-top separate-bottom"></depictions-section>
        </div>
        <div v-if="taxon" class="cright item separate-left">
          <div id="cright-panel">
            <type-box class="separate-bottom"></type-box>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

  import nameSection from './components/nameSection.vue';
  import typeMaterialSection from './components/typeMaterial.vue';
  import depictionsSection from './components/depictionsSection.vue';
  import metadataSection from './components/metadataSection.vue';
  import typeBox from './components/typeBox.vue';
  import spinner from '../components/spinner.vue';

  import ActionNames from './store/actions/actionNames';
  import { GetterNames } from './store/getters/getters';

  export default {
    components: {
      nameSection,
      typeBox,
      typeMaterialSection,
      depictionsSection,
      metadataSection,
      spinner
    },
    computed: {
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      settings() {
        return this.$store.getters[GetterNames.GetSettings]
      }
    },
    mounted: function() {
      let urlParams = new URLSearchParams(window.location.search);
      let protonym_id = urlParams.get('protonym_id');

      if(/^\d+$/.test(protonym_id)) {
        this.$store.dispatch(ActionNames.LoadTypeMaterials, protonym_id)
      }
    }
  }

</script>
<style lang="scss">

  #vue_type_specimens {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    .cleft, .cright {
      min-width: 350px;
      max-width: 350px;
      width: 300px;
    }
    #cright-panel {
      width: 350px;
      max-width: 350px;
    }
    .cright-fixed-top {
      top:68px;
      width: 1240px;
      z-index:200;
      position: fixed;
    }
    .anchor {
       display:block;
       height:65px;
       margin-top:-65px;
       visibility:hidden;
    }


    .types_field {
      input[type="text"], textarea {
        width: 300px;
      }
      .vue-autocomplete-input {
          width: 300px;
      }
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
      .taxonName-input,#error_explanation {
        width: 300px;
      }
    }
  }

</style>