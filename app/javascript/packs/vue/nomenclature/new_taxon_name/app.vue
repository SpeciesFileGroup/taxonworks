<template>
  <div id="new_taxon_name_task">
    <h1>New taxon name</h1>
    <div>
    <nav-header :menu="menu"></nav-header>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <spinner :full-screen="true" legend="Loading..." :logo-size="{ width: '100px', height: '100px'}" v-if="loading"></spinner>
          <basic-information class="separate-bottom"></basic-information>
          <div class="new-taxon-name-block">
            <spinner :show-spinner="false" :show-legend="false" v-if="!getTaxon.id"></spinner>
            <source-picker class="separate-top separate-bottom"></source-picker>
          </div>
          <div class="new-taxon-name-block">
            <spinner :show-spinner="false" :show-legend="false" v-if="!getTaxon.id"></spinner>
            <status-picker class="separate-top separate-bottom"></status-picker>
          </div>
          <div class="new-taxon-name-block">
            <spinner :show-spinner="false" :show-legend="false" v-if="!getTaxon.id"></spinner>
            <relationship-picker class="separate-top separate-bottom"></relationship-picker>
          </div>
          <div class="new-taxon-name-block">
            <type-block v-if="getTaxon.id && showForThisGroup(['FamilyGroup','GenusGroup'])" class="separate-top separate-bottom"></type-block>
          </div>
          <div class="new-taxon-name-block" v-if="showForThisGroup(['SpeciesGroup','GenusGroup'])">
            <spinner :show-spinner="false" :show-legend="false" v-if="!getTaxon.id"></spinner>
            <block-layout anchor="original-combination">
              <h3 slot="header">Original Combination</h3>
              <div slot="body">
                <pick-original-combination></pick-original-combination>
              </div>
            </block-layout>
          </div>
          <div class="new-taxon-name-block" v-if="getTaxon.id && showForThisGroup(['SpeciesGroup','GenusGroup'])">
            <spinner :show-spinner="false" :show-legend="false" v-if="!getTaxon.id"></spinner>
            <etymology class="separate-top separate-bottom"></etymology>
          </div>
          <div class="new-taxon-name-block" v-if="showForThisGroup(['SpeciesGroup','GenusGroup'])">
            <spinner :show-spinner="false" :show-legend="false" v-if="!getTaxon.id"></spinner>
            <gender-block class="separate-top separate-bottom"></gender-block>
          </div>
        </div>
        <div v-if="getTaxon.id" class="cright item separate-left">
          <check-changes></check-changes>
          <taxon-name-box class="separate-bottom"></taxon-name-box>
          <soft-validation class="separate-top"></soft-validation>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  var sourcePicker = require('./components/sourcePicker.vue');
  var relationshipPicker = require('./components/relationshipPicker.vue');
  var statusPicker = require('./components/statusPicker.vue');
  var navHeader = require('./components/navHeader.vue');
  var taxonNameBox = require('./components/taxonNameBox.vue');
  var etymology = require('./components/etymology.vue');
  var genderBlock = require('./components/gender.vue');
  var checkChanges = require('./components/checkChanges.vue');
  var typeBlock = require('./components/type.vue');
  var basicInformation = require('./components/basicInformation.vue');
  var originalCombination = require('./components/originalCombination.vue');
  var pickOriginalCombination = require('./components/pickOriginalCombination.vue');

  var softValidation = require('./components/softValidation.vue');
  var spinner = require('../../components/spinner.vue');
  var blockLayout = require('./components/blockLayout');

  const filterObject = require('./helpers/filterObject');

  const MutationNames = require('./store/mutations/mutations').MutationNames;  
  const GetterNames = require('./store/getters/getters').GetterNames; 
  const ActionNames = require('./store/actions/actions').ActionNames;  


  export default {
    components: {
      etymology,
      sourcePicker,
      spinner,
      navHeader,
      statusPicker,
      taxonNameBox,
      relationshipPicker,
      basicInformation,
      softValidation,
      blockLayout,
      originalCombination,
      pickOriginalCombination,
      typeBlock,
      genderBlock,
      checkChanges
    },
    computed: {
      getTaxon() {
        return this.$store.getters[GetterNames.GetTaxon];
      },
      menu() {
        return {
          'Basic information': true,
          'Author': true,
          'Status': true,
          'Relationship': true,
          'Type': this.showForThisGroup(['SpeciesGroup','GenusGroup']),
          'Original combination': this.showForThisGroup(['SpeciesGroup','GenusGroup']),
          'Etymology': this.showForThisGroup(['SpeciesGroup','GenusGroup']),
          'Gender': this.showForThisGroup(['SpeciesGroup','GenusGroup']),
        }
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
      showForThisGroup: function(findInGroups){
        return (this.getTaxon.rank_string ? (findInGroups.indexOf(this.getTaxon.rank_string.split('::')[2]) > -1) : false);
      },
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
            that.$store.dispatch(ActionNames.LoadSoftValidation, 'taxonStatusList');
            return resolve(true);
          });
        });
      },
      loadTaxonRelationships: function(id) {
        let that = this;
        return new Promise(function (resolve, reject) {
          that.$http.get(`/taxon_names/${id}/taxon_name_relationships`).then( response => {
            that.$store.commit(MutationNames.SetTaxonRelationshipList, response.body);
            that.$store.dispatch(ActionNames.LoadSoftValidation, 'taxonRelationshipList');
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
          console.log(response.body);
          this.loadTaxonRelationships(response.body.id);
          this.loadTaxonStatus(response.body.id);
          this.$store.commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code);
          this.$store.commit(MutationNames.SetTaxon, filterObject(response.body));
          this.$store.dispatch(ActionNames.SetParentAndRanks, response.body.parent);
          this.$store.dispatch(ActionNames.LoadSoftValidation, 'taxon_name');
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

    .cleft, .cright {
      min-width: 350px;
      max-width: 350px;
      width: 300px;
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