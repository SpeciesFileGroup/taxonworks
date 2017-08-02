<template>
	<div id="taxonNameBox">
		<modal v-if="showModal" @close="showModal = false">
			<h3 slot="header">Confirm delete</h3>
			<div slot="body">Are you sure you want to delete <span v-html="parent.object_tag"></span> {{taxon.name}} ?</div>
			<div slot="footer">
				<button @click="deleteTaxon()" type="button" class="normal-input button button-delete align-end">Delete</button>
			</div>
		</modal>
		<div class="panel basic-information">
			<div class="content header">
				<h3 v-if="taxon.id" class="flex-separate middle">
					<span class="taxonname"> 
						<span v-html="parent.object_tag"></span> 
						<span> {{ taxon.name }} </span>
					</span>
					<span v-if="taxon.id" @click="showModal = true" data-icon="trash"></span>
				</h3>
				<h3 class="taxonname" v-else>New</h3>
			</div>
		</div>
	</div>
</template>
<script>

const GetterNames = require('../store/getters/getters').GetterNames
const modal = require('../../../components/modal.vue');

export default {
	components: {
		modal
	},
	data: function() {
		return {
			showModal: false,
		}
	},
	computed: {
		taxon() {
			return this.$store.getters[GetterNames.GetTaxon]
		},
		parent() {
			return this.$store.getters[GetterNames.GetParent]
		}
	},
	methods: {
		deleteTaxon: function() {
			this.$http.delete(`/taxon_names/${this.taxon.id}`).then(response => {
				this.reloadPage();
			});
		},
		reloadPage: function() {
			window.location.href = '/tasks/nomenclature/new_taxon_name/'
		}
	},
}
</script>
<style type="text/css">
#taxonNameBox {
		.header {
			padding: 1em;
			border: 1px solid #f5f5f5;
			.circle-button {
				margin: 0px;
			}
		}
	}
</style>