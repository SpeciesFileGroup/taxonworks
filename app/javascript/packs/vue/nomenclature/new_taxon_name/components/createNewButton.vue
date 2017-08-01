<template>
	<div>
		<modal v-if="showModal" @close="showModal = false">
			<h3 slot="header">Confirm delete</h3>
			<div slot="body">Are you sure you want to create a new taxon name? All unsaved changes will be lost.</div>
			<div slot="footer">
				<button @click="reloadPage()" type="button" class="normal-input button button-default">New</button>
			</div>
		</modal>
		<button type="button" class="normal-input button button-default" @click="showModal = true">New</button>
	</div>
</template>
<script>

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
	methods: {
		reloadPage: function() {
			window.location.href = '/tasks/nomenclature/new_taxon_name/'
		},
	},
}
</script>