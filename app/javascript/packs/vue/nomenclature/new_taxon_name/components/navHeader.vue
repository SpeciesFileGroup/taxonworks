<template>
	<div>
		<div id="taxonNavBar">
			<div class="panel basic-information separate-bottom">
				<div class="content">
					<div class="flex-separate">
						<ul class="no_bullets horizontal_navbar middle">
							<li class="navigation-item" v-for="link,key,index in menu" v-if="link">
								<a :class="{ active : (activePosition == index)}" :href="'#' + key.toLowerCase().replace(' ','-')" @click="activePosition = index">{{key}}</a>
							</li>
						</ul>
						<form class="horizontal-center-content">
							<save-taxon-name v-if="taxon.id" class="normal-input button button-submit"></save-taxon-name>
							<create-new-button ></create-new-button>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</template>
<script>

const saveTaxonName = require('./saveTaxonName.vue');
const createNewButton = require('./createNewButton.vue');
const GetterNames = require('../store/getters/getters').GetterNames;

export default {
	props: {
		menu: {
			type: Object,
			required: true
		}
	},
	components: {
		saveTaxonName,
		createNewButton
	},
	computed: {
		taxon() {
			return this.$store.getters[GetterNames.GetTaxon]
		}
	},
	data: function() {
		return {
			activePosition: 0,
		}
	},
	created: function() {
		$(document).ready(function() {
		  $(window).scroll(function () { 
		    if ($(window).scrollTop() > 150) {
		      $('#taxonNavBar').addClass('navbar-fixed-top');
		    }

		    if ($(window).scrollTop() < 151) {
		      $('#taxonNavBar').removeClass('navbar-fixed-top');
		    }
		  });
		});
	}
}
</script>
<style>
	#taxonNavBar.navbar-fixed-top {
		top:0px;
		width: 1240px;
		z-index:200;
		position: fixed;
	}
	#taxonNavBar {
		button {
			margin-left: 6px;
			min-width: 100px;
			width: 100%;
		}
		.taxonname {
			font-weight: 300;
		}
		li { 
			a {
			font-size: 13px;
			}
			a:first-child {
				padding-left: 0px;
			}
		}
	}
</style>