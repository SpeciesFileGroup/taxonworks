<template>
  <div id="new_taxon_name_task">
  <h1>New taxon name</h1>
    <div class="flexbox horizontal-center-content align-start">
    <div class="cleft item">
      <nav-header></nav-header>
    </div>
    <div class="cright item">
      <spinner :full-screen="true" :logo-size="{ width: '100px', height: '100px'}"v-if="loading"></spinner>
      <basic-information class="separate-bottom"></basic-information>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
        <source-picker class="separate-top separate-bottom"></source-picker>
      </div>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
        <status-picker class="separate-top separate-bottom"></status-picker>
      </div>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
        <relationship-picker class="separate-top separate-bottom"></relationship-picker>
      </div>
      <div class="new-taxon-name-block">
        <spinner :showSpinner="false" :showLegend="false" v-if="!getTaxon.id"></spinner>
        <original-combination class="separate-top separate-bottom"></original-combination>
      </div>
      <soft-validation></soft-validation>
    </div>
  </div>
  </div>
</template>

<script>
  var sourcePicker = require('./components/sourcePicker.vue');
  var relationshipPicker = require('./components/relationshipPicker.vue');
  var statusPicker = require('./components/statusPicker.vue');
  var navHeader = require('./components/navHeader.vue');
  
  var basicInformation = require('./components/basicInformation.vue');
  var originalCombination = require('./components/originalCombination.vue');
  var softValidation = require('./components/softValidation.vue');
  var spinner = require('../../components/spinner.vue');


  const MutationNames = require('./store/mutations/mutations').MutationNames;  
  const GetterNames = require('./store/getters/getters').GetterNames; 
  const ActionNames = require('./store/actions/actions').ActionNames;  


  export default {
    components: {
      sourcePicker,
      spinner,
      navHeader,
      statusPicker,
      relationshipPicker,
      basicInformation,
      softValidation,
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
            source: response.body.source,
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
  #new_taxon_name_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;
    h3 {
      color: #555;
    }
    .cleft {
      width: 300px;
    }
    .cright {
      width: 910px;
    }
    .anchor {
       display:block;
       height:10px;
       margin-top:-10px;
       visibility:hidden;
    }
  }

</style>