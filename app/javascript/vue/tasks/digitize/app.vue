<template>
  <div
    id="#vue-all-in-one"
    v-shortkey="[getMacKey(), 'l']"
    @shortkey="setLockAll">
    <spinner-component
      v-if="saving"
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      legend="Saving changes..."/>
    <task-header/>
    <collection-object class="separate-bottom"/>
    <div class="horizontal-left-content align-start separate-top">
      <div class="separate-right">
        <taxon-determination-layout class="separate-bottom"/>
        <type-material class="separate-top"/>
      </div>
      <collection-event-layout class="separate-left"/>
    </div>
  </div>
</template>

<script>
  import TaskHeader from './components/taskHeader/main.vue'
  import CatalogueNumber from './components/catalogueNumber/catalogNumber.vue'
  import CollectionObject from './components/collectionObject/main.vue'
  import TaxonDeterminationLayout from './components/taxonDetermination/main.vue'
  import CollectionEventLayout from './components/collectionEvent/main.vue'
  import TypeMaterial from './components/typeMaterial/typeMaterial.vue'
  import { GetUserPreferences, GetIdentifier } from './request/resources.js'
  import { MutationNames } from './store/mutations/mutations.js'
  import { ActionNames } from './store/actions/actions.js'
  import { GetterNames } from './store/getters/getters.js'
  import SpinnerComponent from 'components/spinner.vue'
  import ContainerItems from './components/collectionObject/containerItems.vue'

  export default {
    components: {
      TaskHeader,
      CollectionObject,
      TypeMaterial,
      TaxonDeterminationLayout,
      CollectionEventLayout,
      CatalogueNumber,
      SpinnerComponent,
      ContainerItems
    },
    computed: {
      saving() {
        return this.$store.getters[GetterNames.IsSaving]
      }
    },
    mounted() {
      let coId = location.pathname.split('/')[4]

      GetUserPreferences().then(response => {
        this.$store.commit(MutationNames.SetPreferences, response)
      })

      if (/^\d+$/.test(coId)) {
        this.$store.dispatch(ActionNames.LoadDigitalization, coId)
      }
    },
    methods: {
      getMacKey() {
        return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
      },
      setLockAll() {
        this.$store.commit(MutationNames.LockAll)
      }
    }
  }
</script>
<style lang="scss">
  #vue_new_matrix_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    .cleft, .cright {
      min-width: 450px;
      max-width: 450px;
      width: 400px;
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
  }
</style>
