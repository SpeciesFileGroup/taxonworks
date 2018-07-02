<template>
  <div id="#vue-all-in-one">
    <div class="horizontal-left-content">
      <div>
        <taxon-determination-layout/>
        <type-material/>
      </div>
      <collection-event-layout/>
    </div>
  </div>
</template>

<script>
  import TaxonDeterminationLayout from './components/taxonDetermination/main.vue'
  import CollectionEventLayout from './components/collectionEvent/main.vue'
  import TypeMaterial from './components/typeMaterial/typeMaterial.vue'

  export default {
    components: {
      TypeMaterial,
      TaxonDeterminationLayout,
      CollectionEventLayout
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
