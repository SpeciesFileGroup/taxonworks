<template>
<div>
	<div id="taxonNavBar">
		<div class="panel separate-bottom">
			<div class="content">
				<div v-if="taxon.id" class="flex-separate middle">
					<span class="taxonname"> 
						<span v-html="parent.object_tag"></span> 
						<span> {{ taxon.name }} </span>
					</span>
					<span v-if="taxon.id" class="circle-button btn-delete"></span>
				</div>
				<span class="taxonname" v-else>New</span>
				
			</div>
			<div class="content">
				<div class="flex-separate">
					<ul class="no_bullets">
						<li class="navigation-item" v-for="link,key,index in anchorLink">
							<a :class="{ active : (activePosition == index)}" :href="anchorLink[key]" @click="activePosition = index" >{{key}}</a>
						</li>
					</ul>
				</div>
			</div>
		</div>
		<form class="separate-top separate-bottom horizontal-center-content">
			<button type="button" class="normal-input button button-default" @click="reloadPage()">New</button>
			<save-taxon-name class="normal-input button button-submit"></save-taxon-name>
		</form>
	</div>
</div>
</template>
<script>

const GetterNames = require('../store/getters/getters').GetterNames
const saveTaxonName = require('./saveTaxonName.vue');

export default {

	components: {
		saveTaxonName
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
			activePosition: 0,
			anchorLink: {
				'Basic information': '#basic-information',
				'Author': '#author',
				'Status': '#status',
				'Relationship': '#relationship',
				'Original combination': '#original-combination'
			}
		}
	},
	methods: {
		reloadPage: function() {
			window.location.href = '/tasks/nomenclature/new_taxon_name/'
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
		z-index:200;
		position: fixed;
	}
	#taxonNavBar {
		width: 300px;
		button {
			margin: 6px;
			width: 100%;
		}
		.taxonname {
			font-size: 120%;
		}
		.horizontal_navbar {
			padding-left: 0px;
			a {
				width: 100%;
			}
		}
	}
</style>