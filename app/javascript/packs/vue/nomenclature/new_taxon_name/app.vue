<template>
  <div id="new_taxon_name_task">
    <spinner :full-screen="true" :logo-size="{ width: '100px', height: '100px'}"v-if="loading"></spinner>
    <h1>New taxon name</h1>
    <div>
      <basic-information></basic-information>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
        <source-picker class="separate-top"></source-picker>
      </div>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
      <status-picker class="separate-top"></status-picker>
      </div>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
        <relationship-picker class="separate-top"></relationship-picker>
      </div>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
        <original-combination class="separate-top"></original-combination>
      </div>
    </div>
  </div>
</template>

<script>
  var sourcePicker = require('./components/sourcePicker.vue');
  var relationshipPicker = require('./components/relationshipPicker.vue');
  var statusPicker = require('./components/statusPicker.vue');
  
  var basicInformation = require('./components/basicInformation.vue');
  var originalCombination = require('./components/originalCombination.vue');
  var spinner = require('../../components/spinner.vue');


  const MutationNames = require('./store/mutations/mutations').MutationNames;  
  const GetterNames = require('./store/getters/getters').GetterNames; 
  const ActionNames = require('./store/actions/actions').ActionNames;  


  export default {
    components: {
      sourcePicker,
      spinner,
      statusPicker,
      relationshipPicker,
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
    data: function() {
      return {
        loading: true
      }
    },
    mounted: function() {
      let that = this;
      let taxonId = location.pathname.split('/')[4];
      this.initLoad().then(function() {
        if(/^\d+$/.test(taxonId)) {
          that.fillTaxonName(taxonId);
        }
        else {
          that.loading = false;
        }
      });
    },
    methods: {
      loadRanks: function() {
        let that = this;
        return new Promise(function (resolve, reject) {
          that.$http.get('/taxon_names/ranks').then( response => {
            that.$store.commit(MutationNames.SetRankList, response.body);
           return resolve(true);
        });
      });
         
      },
      loadStatus: function() {
        let that = this;
        return new Promise(function (resolve, reject) {
          that.$http.get('/taxon_name_classifications/taxon_name_classification_types').then( response => {
            that.$store.commit(MutationNames.SetStatusList, response.body);
            return resolve(true);
          });
        });
      },
      loadRelationship: function() {
        let that = this;
        return new Promise(function (resolve, reject) {
          that.$http.get('/taxon_name_relationships/taxon_name_relationship_types').then( response => {
            that.$store.commit(MutationNames.SetRelationshipList, response.body);
            return resolve(true);
          });
        });
      },
      loadTaxonStatus: function(id) {
        let that = this;
        return new Promise(function (resolve, reject) {
          that.$http.get(`/taxon_names/${id}/taxon_name_classifications`).then( response => {
            that.$store.commit(MutationNames.SetTaxonStatusList, response.body);
            return resolve(true);
          });
        });
      },
      initLoad: function() {
        let that = this;
        return new Promise(function (resolve, reject) {
          return resolve(that.loadRanks().then(that.loadStatus).then(that.loadRelationship));
        });
      },
      fillTaxonName: function(id) {
        this.$http.get(`/taxon_names/${id}`).then( response => {
          let taxon_name = {
            id: response.body.id,
            parent_id: response.body.parent_id,
            name: response.body.name,
            rank_class: response.body.rank_string,
            year_of_publication: response.body.year_of_publication,
            verbatim_author: response.body.verbatim_author,
            feminine_name: response.body.feminine_name,
            masculine_name: response.body.masculine_name,
            neuter_name: response.body.neuter_name,
          }
          this.loadTaxonStatus(response.body.id);
          this.$store.commit(MutationNames.SetSource, response.body.source);
          this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code);
          this.$store.commit(MutationNames.SetTaxon, taxon_name);
          this.$store.dispatch(ActionNames.SetParentAndRanks, response.body.parent);
          this.loading = false;
        }, response => {
          TW.workbench.alert.create("There is no taxon name associated to that ID", "error");
        });
      },
    }      
  }

</script>
<style type="text/css">
  .new-taxon-name-block {
    width: 924px;
  }
</style>