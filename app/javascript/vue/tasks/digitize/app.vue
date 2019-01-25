<template>
  <div
    id="vue-all-in-one"
    v-shortkey="[getMacKey(), 'l']"
    @shortkey="setLockAll">
    <spinner-component
      v-if="saving || loading"
      :full-screen="true"
      :logo-size="{ width: '100px', height: '100px'}"
      :legend="(saving ? 'Saving changes...' : 'Loading...')"/>
    <task-header/>
    <collection-object class="separate-bottom"/>
    <div class="horizontal-left-content align-start separate-top main-panel">
      <div class="separate-right left-section">
        <taxon-determination-layout class="separate-bottom"/>
        <type-material class="separate-top"/>
      </div>
      <collection-event-layout class="separate-left item ce-section"/>
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
  import { GetUserPreferences } from './request/resources.js'
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
      },
      loading() {
        return this.$store.getters[GetterNames.IsLoading]
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
  #vue-all-in-one {

    .switch-radio {
      flex: 1 auto;
      label {
        width: 100% !important; 
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
  }
</style>
