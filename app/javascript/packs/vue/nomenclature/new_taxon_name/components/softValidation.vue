<template>
	<transition name="slide-fade">
		<div v-if="errors" class="soft-validation-box">
		<div class="header flex-separate"><h3>Soft Validation</h3> <span @click="close()" class="small-icon" data-icon="close"></span></div>
			<div class="body">
				<ul class="" v-for="key in Object.keys(errors)">
					<li v-for="description in errors[key]"> {{ description }} </li>
				</ul>
			</div>
		</div>
	</transition>
</template>

<script>

const GetterNames = require('../store/getters/getters').GetterNames;
const MutationNames = require('../store/mutations/mutations').MutationNames;

export default {
	computed: {
		errors() {
			return this.$store.getters[GetterNames.GetSoftValidation]
		}
	},
	watch: {
		errors: function(val) {
			if(val) {
				TW.workbench.alert.play();
			}
		}
	},
	methods: {
		close: function() {
			this.$store.commit(MutationNames.SetSoftValidation, undefined);
		}
	}
}
</script>
<style type="text/css">
	.soft-validation-box {
		background-color: #FFF9F9;
		border-left: 4px solid red;
		box-shadow: 0 0 4px 0 rgba(0,0,0,0.2);
		position: fixed;
		bottom: 0px;
		z-index:999;
		width: 500px;
		left:50%;
		transform: translate(-50%, 0%);
		
		.body {
			padding: 12px;
		}
		.header {
			padding-left: 12px;
			padding-right: 12px;
		}
		ul {
			margin: 0px;
			padding: 0px;
			padding-left: 15px;
		}
		li:first-letter {
			text-transform: capitalize;
		}
	}
	.slide-fade-enter-active {
	  transition: all .3s ease;
	  left:50%;
	  transform: translate(-50%, 0%);
	}
	.slide-fade-leave-active {
	  transition: all .3s cubic-bezier(1.0, 0.5, 0.8, 1.0);
	}
	.slide-fade-enter, .slide-fade-leave-to
	/* .slide-fade-leave-active for <2.1.8 */ {
		transform: translate(-50%, 50%);
	  opacity: 0;
	}
</style>