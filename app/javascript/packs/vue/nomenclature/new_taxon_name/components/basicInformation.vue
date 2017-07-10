<template>
    <form class="content panel basic-information">
      <div class="header">
        <h3 class="">Basic information</h3>
      </div>
      <div class="body horizontal-left-content align-start">
        <div class="column-left">
          <div class="field separate-top">
            <label>Parent</label>
            <parent-picker></parent-picker>
          </div>
          <div class="field separate-right">
          	<label>Name</label><br>
          	<taxon-name></taxon-name>
          </div>
          <rank-selector></rank-selector>
          <button type="button" @click="taxon.id == undefined ? createTaxonName() : updateTaxonName()" :disabled="!(parent && taxon.name)" class="button normal-input">{{ taxon.id == undefined ? 'Create': 'Update' }}</button>
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
  var checkExist = require('./findExistTaxonName.vue');
  var rankSelector = require('./rankSelector.vue');

	export default {
		components: {
			parentPicker,
			taxonName,
			rankSelector,
      checkExist
		},
    computed: {
      parent() {
        return this.$store.getters[GetterNames.GetParent]
      },
      taxon() {
        return this.$store.getters[GetterNames.GetTaxon]
      }
    },
    methods: {
      createTaxonName: function() {
        var taxon_name = {
          taxon_name: {
            name: this.taxon.name,
            parent_id: this.taxon.parent_id,
            rank_class: this.taxon.rank_class,
            type: 'Protonym'
          }
        }
        this.$http.post('/taxon_names.json', taxon_name).then(response => {
          this.$store.commit(MutationNames.SetTaxonId, response.body.id);
          TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully created.`, "notice");
        });
      },
      updateTaxonName: function() {
        var taxon_name = {
          taxon_name: {
            name: this.taxon.name,
            parent_id: this.taxon.parent_id,
            rank_class: this.taxon.rank_class,
            type: 'Protonym'
          }
        }        
        this.$http.patch(`/taxon_names/${this.taxon.id}.json`, taxon_name).then(response => {
          TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully updated.`, "notice");
        });
      }
    }
	}
</script>

<style type="text/css">
  .basic-information {
    height: 100%;
    display: flex;
    flex-direction: column;
    .header {
      border-bottom: 1px solid #f5f5f5;
    }
    .body {
      padding: 12px;
    }
    .vue-autocomplete-input {
      width: 300px;
    }
    .taxonName-input {
      width: 300px;
    }

    width: 900px;
    padding: 12px;
    box-shadow: 0 0 2px 0px rgba(0,0,0,0.2);
  }
</style>