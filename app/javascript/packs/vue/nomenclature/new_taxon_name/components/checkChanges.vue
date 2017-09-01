<template>
	<transition name="fade">
		<div id="check-unsaved" class="panel content soft-validation-box" v-if="unsavedChanges">
			<span data-icon="warning">You have unsaved changes.</span>
		</div>
	</transition>
</template>

<script>

  	const GetterNames = require('../store/getters/getters').GetterNames;

	export default {
		computed: {
			unsavedChanges() {
				return (this.$store.getters[GetterNames.GetLastChange] > this.$store.getters[GetterNames.GetLastSave])
			},
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon]
			}
		},
		data: function() {
			return {
			copyVal: undefined,
			filterCompare: 
				['name',
				 'parent',
				 'verbatim_author',
				 'rank_string',
				 'year_of_publication',
				 'feminine_name',
				 'masculine_name',
				 'neuter_name',
				 'etymology'
				]
			}
		},
	}
</script>

<style type="text/css">
	.fade-enter-active, .fade-leave-active {
	  transition: opacity .5s
	}
	.fade-enter, .fade-leave-to {
	  opacity: 0
	}

	#check-unsaved {
		bottom: 20px;
		right: 0px;
	}
</style>