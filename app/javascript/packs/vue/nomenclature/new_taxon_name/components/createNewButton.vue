<template>
	<div>
		<modal v-if="showModal" @close="showModal = false">
			<h3 slot="header">Confirm</h3>
			<div slot="body">Are you sure you want to create a new taxon name? All unsaved changes will be lost.</div>
			<div slot="footer">
				<button @click="reloadPage()" type="button" class="normal-input button button-default">New</button>
			</div>
		</modal>
		<button type="button" class="normal-input button button-default" @click="createNew()">New</button>
	</div>
</template>
<script>

const GetterNames = require('../store/getters/getters').GetterNames;
const modal = require('../../../components/modal.vue').default;

export default {
	components: {
		modal
	},
	computed: {
		unsavedChanges() {
			return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
		},
	},
	data: function() {
		return {
			showModal: false,
		}
	},
	methods: {
		reloadPage: function() {
			window.location.href = '/tasks/nomenclature/new_taxon_name/'
		},
		createNew() {
			if(this.unsavedChanges) {
				this.showModal = true;
			}
			else {
				this.reloadPage();
			}
		}
	},
}
</script>