<template>
  <div id="new_taxon_name_task">
    <h1>New taxon name</h1>
    <div class="panel content">
      <form class="content">
        <h3 class="subtitle">Basic information</h3><br>
        <div class="field separate-top">
          <label>Parent</label>
          <parent-picker></parent-picker>
        </div>
        <div class="field">
          <label>Name</label><br>
          <taxon-name></taxon-name>
        </div>
        <rank-selector></rank-selector>
      </form>

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
      <status-picker></status-picker>
      <relationship-picker></relationship-picker>
    </div>
  </div>
</template>

<script>
  var parentPicker = require('./components/parentPicker.vue');
  var taxonName = require('./components/taxonName.vue');
  var rankSelector = require('./components/rankSelector.vue');
  var sourcePicker = require('./components/sourcePicker.vue');
  var verbatimAuthor = require('./components/verbatimAuthor.vue');
  var verbatimYear = require('./components/verbatimYear.vue');
  var relationshipPicker = require('./components/relationshipPicker.vue');
  var statusPicker = require('./components/statusPicker.vue');


  const MutationNames = require('./store/mutations/mutations').MutationNames;  


  export default {
    components: {
      parentPicker,
      taxonName,
      rankSelector,
      sourcePicker,
      verbatimAuthor,
      verbatimYear,
      statusPicker,
      relationshipPicker
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