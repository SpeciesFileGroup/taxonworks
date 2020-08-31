<template>
  <div id="vue_type_specimens">
    <spinner
      v-if="settings.loading || settings.saving"
      :full-screen="true"
      :legend="(settings.loading ? 'Loading...' : 'Saving...')"
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div class="flex-separate middle">
      <h1>{{ isNew }} type specimen</h1>
      <span
        @click="reloadApp"
        data-icon="reset"
        class="middle reload-app">Reset</span>
    </div>
    <div>
      <div
        v-shortkey="[getOSKey(), 't']"
        @shortkey="switchTaxonNameTask()"
        class="align-start">
        <div class="ccenter item separate-right">
          <name-section
            class="separate-bottom"
            v-if="!taxon"/>
          <metadata-section class="separate-bottom"/>
          <type-material-section class="separate-bottom"/>
        </div>
        <div
          v-if="taxon"
          class="cright item separate-left">
          <div id="cright-panel">
            <type-box class="separate-bottom"/>
            <soft-validation/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import SoftValidation from './components/softValidation.vue'
import nameSection from './components/nameSection.vue'
import typeMaterialSection from './components/typeMaterial.vue'
import metadataSection from './components/metadataSection.vue'
import typeBox from './components/typeBox.vue'
import spinner from 'components/spinner.vue'

import ActionNames from './store/actions/actionNames'
import { GetterNames } from './store/getters/getters'
import GetOSKey from 'helpers/getMacKey.js'

import setParamsId from './helpers/setParamsId'

export default {
  components: {
    SoftValidation,
    nameSection,
    typeBox,
    typeMaterialSection,
    metadataSection,
    spinner
  },
  computed: {
    taxonMaterial () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    settings () {
      return this.$store.getters[GetterNames.GetSettings]
    },
    isNew () {
      return this.$store.getters[GetterNames.GetTypeMaterial].id ? 'Edit' : 'New'
    }
  },
  mounted: function () {
    this.loadTaxonTypes()
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+t`, 'Go to new taxon name task', 'New type material')
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+o`, 'Go to browse OTU', 'New type material')
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+e`, 'Go to comprehensive specimen digitization', 'New type material')
    TW.workbench.keyboard.createLegend(`${this.getOSKey()}+b`, 'Go to browse nomenclature', 'New type material')
  },
  watch: {
    taxon (newVal) {
      if (newVal != undefined) {
        setParamsId('taxon_name_id', newVal.id)
      }
    }
  },
  methods: {
    reloadApp: function () {
      window.location.href = '/tasks/type_material/edit_type_material'
    },
    loadTaxonTypes () {
      let urlParams = new URLSearchParams(window.location.search)
      let protonymId = urlParams.get('protonym_id')
      if(!protonymId) {
        protonymId = urlParams.get('taxon_name_id')
      }
      let typeId = urlParams.get('type_material_id')

      if (/^\d+$/.test(protonymId)) {
        this.$store.dispatch(ActionNames.LoadTaxonName, protonymId).then((response) => {
          this.$store.dispatch(ActionNames.LoadTypeMaterials, protonymId).then(response => {
            if (/^\d+$/.test(protonymId)) {
              this.loadType(response, typeId)
            }
          })
        })
      }
    },
    loadType (list, typeId) {
      let findType = list.find((type) => {
        return type.id == typeId
      })
      if (findType) {
        this.$store.dispatch(ActionNames.LoadTypeMaterial, findType)
      }
    },
    switchTaxonNameTask () {
      let urlParams = new URLSearchParams(window.location.search)
      let taxonId = urlParams.get('taxon_name_id')
      if (taxonId) {
        window.open(`/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxonId}`, '_self')
      } else {
        window.open('/tasks/nomenclature/new_taxon_name', '_self')
      }
    },
    getOSKey: GetOSKey
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
