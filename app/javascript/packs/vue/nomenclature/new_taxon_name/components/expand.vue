<template>
	<div>
		<span @click="$emit('changed')" data-icon="contract" v-if="expanded"></span>
		<span @click="$emit('changed')" data-icon="expand" v-else></span>
	</div>
</template>
<script>

export default {
	props: {
		expanded: {
			type: Boolean
		}
	}
}
</script>