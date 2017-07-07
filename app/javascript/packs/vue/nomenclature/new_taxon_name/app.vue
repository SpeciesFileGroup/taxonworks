<template>
  <div id="new_taxon_name_task">
    <h1>New taxon name</h1>
    <div>
      <basic-information></basic-information>
      <source-picker class="separate-top"></source-picker>
      <form class="content">
        <div class="field separate-top">

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
  const GetterNames = require('./store/getters/getters').GetterNames; 
  const ActionNames = require('./store/actions/actions').ActionNames;  


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
    computed: {
      getTaxon() {
        return this.$store.getters[GetterNames.GetTaxon];
      },
      getParent() {
        return this.$store.getters[GetterNames.GetParent];
      }
    },
    mounted: function() {
      let taxonId = location.pathname.split('/')[4];
        this.loadRanks();
        this.loadStatus();
        this.loadRelationship();
        if(/^\d+$/.test(taxonId)) {
          this.fillTaxonName(taxonId);
        }
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
      },
      fillTaxonName: function(id) {
        this.$http.get(`/taxon_names/${id}`).then( response => {
          console.log(response.body);
          let taxon_name = {
            id: response.body.id,
            parent_id: response.body.parent_id,
            name: response.body.name,
            rank_class: response.body.rank,
            year_of_publication: response.body.year_of_publication,
            verbatim_author: response.body.year_of_publication,
            feminine_name: response.body.feminine_name,
            masculine_name: response.body.masculine_name,
            neuter_name: response.body.neuter_name,
          }
          //this.$store.commit(MutationNames.GetRelatioships, response.body.source);
          this.$store.commit(MutationNames.SetSource, response.body.source);
          this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code);
          this.$store.commit(MutationNames.SetTaxon, taxon_name);
          this.$store.dispatch(ActionNames.SetParentAndRanks, response.body.parent);
        }, response => {
          TW.workbench.alert.create("There is no taxon name associated to that ID", "error");
        });
      },
    }      
  }

</script>