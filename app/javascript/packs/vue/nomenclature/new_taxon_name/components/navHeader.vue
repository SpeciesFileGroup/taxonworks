<template>
<div>
	<div id="taxonNavBar">
		<div class="panel basic-information separate-bottom">
			<div class="content">
				<div class="flex-separate">
					<ul class="no_bullets horizontal_navbar middle">
						<li class="navigation-item" v-for="link,key,index in anchorLink">
							<a :class="{ active : (activePosition == index)}" :href="anchorLink[key]" @click="activePosition = index" >{{key}}</a>
						</li>
					</ul>
					<form class="horizontal-center-content">
						<save-taxon-name class="normal-input button button-submit"></save-taxon-name>
						<button type="button" class="normal-input button button-default" @click="reloadPage()">New</button>
					</form>
				</div>
			</div>
		</div>

	</div>
</div>
</template>
<script>

const GetterNames = require('../store/getters/getters').GetterNames
const saveTaxonName = require('./saveTaxonName.vue');

export default {

	components: {
		saveTaxonName,
	},
	computed: {
		taxon() {
			return this.$store.getters[GetterNames.GetTaxon]
		},
		parent() {
			return this.$store.getters[GetterNames.GetParent]
		}
	},
	data: function() {
		return {
			showModal: false,
			activePosition: 0,
			anchorLink: {
				'Basic information': '#basic-information',
				'Author': '#author',
				'Status': '#status',
				'Relationship': '#relationship',
				'Original combination': '#original-combination',
				'Etymology': '#etymology',
				'Gender': '#gender'
			}
		}
	},
	methods: {
		reloadPage: function() {
			window.location.href = '/tasks/nomenclature/new_taxon_name/'
		},
		deleteTaxon: function() {
			this.$http.delete(`/taxon_names/${this.taxon.id}`).then(response => {
				this.reloadPage();
			});
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