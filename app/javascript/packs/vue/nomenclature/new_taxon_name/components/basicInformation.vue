<template>
    <form class="content panel basic-information">
    <a name="basic-information" class="anchor"></a>
      <div class="header flex-separate">
        <h3 class="">Basic information</h3>
        <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
      </div>
      <div class="body horizontal-left-content align-start" v-show="expanded">
        <div class="column-left">
          <div class="field separate-top">
            <label>Parent</label>
            <parent-picker></parent-picker>
          </div>
          <div class="field separate-right">
          	<label>Name</label><br>
          	<taxon-name :class="{ field_with_errors : existError('name') }"></taxon-name>
          </div>
          <rank-selector></rank-selector>

        </div>
        <div class="column-right item">
          <check-exist class="separate-left" url="/taxon_names/autocomplete" label="label_html" :search="taxon.name" param="term" :add-params="{ exact: true }"></check-exist>
        </div>
        </div>
      </form>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

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
      checkExist
		},
    computed: {
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      },
      errors() {
        return this.$store.getters[GetterNames.GetSoftValidation]
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
    height: 100%;
    box-sizing: border-box;
    padding: 12px;
    box-shadow: 0 0 2px 0px rgba(0,0,0,0.2);
    display: flex;
    flex-direction: column;
    .header {
      padding-left: 12px;
      border-bottom: 1px solid #f5f5f5;
    }
    .body {
      padding: 12px;
    }
    .vue-autocomplete-input {
      width: 300px;
    }
    .taxonName-input,#error_explanation {
      width: 300px;
    }
  }
</style>