<template>
    <form class="panel basic-information">
    <a name="basic-information" class="anchor"></a>
      <div class="header flex-separate middle">
        <h3 class="">Basic information</h3>
        <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
      </div>
      <div class="body horizontal-left-content align-start" v-show="expanded">
        <div class="column-left">
          <div class="field separate-right">
          	<label>Name</label><br>
          	<taxon-name :class="{ field_with_errors : existError('name') }"></taxon-name>
          </div>
          <div class="field separate-top">
            <label>Parent</label>
            <parent-picker></parent-picker>
          </div>
          <rank-selector v-if="parent"></rank-selector>
          
        </div>
        <div class="column-right item">
          <check-exist class="separate-left" url="/taxon_names/autocomplete" label="label_html" :search="taxon.name" param="term" :add-params="{ exact: true }"></check-exist>
        </div>
      </div>
      <div class="body" v-if="taxon.name && taxon.rank_string && !taxon.id">
        <save-taxon-name class="normal-input button button-submit create-button"></save-taxon-name>
      </div>
    </form>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

  var saveTaxonName = require('./saveTaxonName.vue');
  var parentPicker = require('./parentPicker.vue');
  var taxonName = require('./taxonName.vue');
  var expand = require('./expand.vue');
  var checkExist = require('./findExistTaxonName.vue');
  var rankSelector = require('./rankSelector.vue');

	export default {
		components: {
			parentPicker,
			taxonName,
      expand,
			rankSelector,
      checkExist,
      saveTaxonName
		},
    computed: {
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      errors() {
        return this.$store.getters[GetterNames.GetHardValidation]
      }
    },
    data: function() {
      return {
        expanded: true
      }
    },
    methods: {
      existError: function(type) {
        return (this.errors && this.errors.hasOwnProperty(type));
      }
    }
	}
</script>

<style type="text/css">
  .basic-information {
    .validation-warning {
      border-left: 4px solid #ff8c00 !important;
    }
    .create-button {
      min-width: 100px;
    }
    .soft-success {

    }
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
    .vue-autocomplete-input {
      width: 300px;
    }
    .taxonName-input,#error_explanation {
      width: 300px;
    }
  }
</style>