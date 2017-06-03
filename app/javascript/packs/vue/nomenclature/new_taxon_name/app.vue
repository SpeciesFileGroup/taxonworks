<template>
  <div id="new_taxon_name_task">
    <h1>New taxon name</h1>
    <div class="panel content">
      <basic-information></basic-information>
      <form class="content">
        <h3 class="">Author/year</h3><br>
        <div class="field separate-top">
          <label>Source</label>
          <source-picker></source-picker>
        </div>      
        <div class="field separate-top">
          <label>Verbatim author</label><br>
          <verbatim-author></verbatim-author>
        </div>
        <div class="fields">
          <label>Verbatim year</label><br>
          <verbatim-year></verbatim-year>
        </div>
      </form>
      <div>
        <status-picker></status-picker>
        <list-entrys mutationNameRemove="RemoveTaxonStatus" list="GetTaxonStatusList" display="name"></list-entrys>
      </div>
      <div>
        <relationship-picker></relationship-picker>
        <taxon-name-picker></taxon-name-picker>
        <list-entrys mutationNameRemove="RemoveTaxonRelationship" list="GetTaxonRelationshipList" display="subject_status_tag"></list-entrys>
      </div>
      <div>
        <original-combination></original-combination>
      </div>
    </div>
  </div>
</template>

<script>
  var sourcePicker = require('./components/sourcePicker.vue');
  var verbatimAuthor = require('./components/verbatimAuthor.vue');
  var verbatimYear = require('./components/verbatimYear.vue');
  var relationshipPicker = require('./components/relationshipPicker.vue');
  var statusPicker = require('./components/statusPicker.vue');
  var listEntrys = require('./components/listEntrys.vue');
  var taxonNamePicker = require('./components/taxonNamePicker.vue');
  var basicInformation = require('./components/basicInformation.vue');
  var originalCombination = require('./components/originalCombination.vue');


  const MutationNames = require('./store/mutations/mutations').MutationNames;  


  export default {
    components: {
      sourcePicker,
      verbatimAuthor,
      verbatimYear,
      statusPicker,
      relationshipPicker,
      listEntrys,
      taxonNamePicker,
      basicInformation,
      originalCombination
    },
    mounted: function() {
      this.loadRanks();
      this.loadStatus();
      this.loadRelationship();
    },
    methods: {
      loadRanks: function() {
        this.$http.get('/taxon_names/ranks').then( response => {
          this.$store.commit(MutationNames.SetRankList, response.body);
        });
      },
      loadStatus: function() {
        this.$http.get('/taxon_name_classifications/taxon_name_classification_types').then( response => {
          this.$store.commit(MutationNames.SetStatusList, response.body);
        });
      },
      loadRelationship: function() {
        this.$http.get('/taxon_name_relationships/taxon_name_relationship_types').then( response => {
          this.$store.commit(MutationNames.SetRelationshipList, response.body);
        });
      }
    }      
  }

</script>