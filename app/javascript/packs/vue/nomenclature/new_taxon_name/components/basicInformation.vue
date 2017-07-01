<template>
    <form class="content">
        <h3 class="subtitle">Basic information</h3><br>
        <div class="field separate-top">
	        <label>Parent</label>
	        <parent-picker></parent-picker>
        </div>
        <div class="horizontal-left-content align-start">
          <div class="field">
          	<label>Name</label><br>
          	<taxon-name></taxon-name>
          </div>
          <div>
            <check-exist class="separate-left" url="/taxon_names/autocomplete" label="label_html" :search="taxon.name" param="term" :add-params="{ exact: true }"></check-exist>
          </div>
        </div>
        <rank-selector></rank-selector>
        <button type="button" @click="createTaxonName()" :disabled="!(parent && taxon.name)" class="button">Create</button>
      </form>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;

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
        var token = $('[name="csrf-token"]').attr('content');
        this.$http.headers.common['X-CSRF-Token'] = token;
        this.$http.post('/taxon_names.json', taxon_name).then(response => {
          console.log(response);
        });
      }
    }
	}
</script>