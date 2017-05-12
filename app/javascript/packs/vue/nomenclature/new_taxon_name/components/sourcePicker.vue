<template>
	<autocomplete
		url="/sources/autocomplete"
		min="3"
		param="term"
		label="label_html"
		display="label">
	</autocomplete>
</template>

<script>

 	const autocomplete = require('../../../components/autocomplete.vue');

	export default {
		components: {
			autocomplete
		}
	};
</script>