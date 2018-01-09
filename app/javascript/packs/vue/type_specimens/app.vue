<template>
  <div id="vue_type_specimens">
    <spinner 
      v-if="settings.loading || settings.saving"
      :full-screen="true" 
      :legend="(settings.loading ? 'Loading...' : 'Saving...')" 
      :logo-size="{ width: '100px', height: '100px'}">
    </spinner>
    <div class="flex-separate middle">
      <h1>{{ isNew }} type specimen</h1>
      <span @click="reloadApp" data-icon="reset" class="middle reload-app">Reset</span>
    </div>
    <div>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <name-section class="separate-bottom" v-if="!taxon"></name-section>
          <metadata-section class="separate-bottom"></metadata-section>
          <type-material-section class="separate-bottom"></type-material-section>
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
  import metadataSection from './components/metadataSection.vue';
  import typeBox from './components/typeBox.vue';
  import spinner from '../components/spinner.vue';

  import ActionNames from './store/actions/actionNames';
  import { GetterNames } from './store/getters/getters';

  import setParamsId from './helpers/setParamsId';

  export default {
    components: {
      nameSection,
      typeBox,
      typeMaterialSection,
      metadataSection,
      spinner
    },
    computed: {
      taxonMaterial() {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      settings() {
        return this.$store.getters[GetterNames.GetSettings]
      },
      isNew() {
        return this.$store.getters[GetterNames.GetTypeMaterial].id ? 'Edit' : 'New'
      }
    },
    mounted: function() {
      this.loadTaxonTypes();
    },
    watch: {
      taxon(newVal) {
        if(newVal != undefined) {
          setParamsId('protonym_id', newVal.id);
        }
      }
    },
    methods: {
      reloadApp: function() {
        window.location.href = '/tasks/type_material/edit_type_material'
      },
      loadTaxonTypes() {
        let urlParams = new URLSearchParams(window.location.search);
        let protonym_id = urlParams.get('protonym_id');
        let type_id = urlParams.get('type_material_id');

        if(/^\d+$/.test(protonym_id)) {
          this.$store.dispatch(ActionNames.LoadTaxonName, protonym_id).then((response) => {
            this.$store.dispatch(ActionNames.LoadTypeMaterials, protonym_id).then(response => {
              if(/^\d+$/.test(protonym_id)) {
                this.loadType(response, type_id)
              }
            })
          })
        }
      },
      loadType(list, type_id) {
        let findType = list.find((type) => {
          return type.id == type_id
        })
        if(findType) {
          this.$store.dispatch(ActionNames.LoadTypeMaterial, findType)
        }
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
    .reload-app {
      cursor: pointer;
      &:hover {
        opacity: 0.8;
      }
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