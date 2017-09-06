<template>
	<form>
		<div class="basic-information panel">
			<a name="author" class="anchor"></a>
			<div class="header flex-separate middle">
				<h3>Author</h3>
				<expand @changed="expanded = !expanded" :expanded="expanded"></expand>
			</div>
			<div class="body" v-show="expanded">
				<div class="separate-bottom">
			        <div class="switch-radio">
						<input name="author-picker-options" id="author-picker-source" checked type="radio" class="normal-input button-active" v-model="show" value="source"/>
						<label for="author-picker-source" class="">
							<span>Source</span> 
							<div v-if="citation"><span class="small-icon icon-without-space" data-icon="ok"></span></div>
							</label>
						<input name="author-picker-options" id="author-picker-verbatim" type="radio" class="normal-input" v-model="show" value="verbatim"/>
						<label for="author-picker-verbatim">
							Verbatim
							<div v-if="verbatimFieldsWithData"><span class="small-icon icon-without-space" data-icon="ok"></span></div>
						</label>
						<input name="author-picker-options" id="author-picker-person" type="radio" class="normal-input" v-model="show" value="person"/>
						<label for="author-picker-person">
							<span>Person</span> 
							<span v-if="roles.length">({{ roles.length }})</span>
						</label>
			        </div>
			    </div>
			    <div v-if="show == 'source'">
				    <div class="horizontal-left-content">
						<autocomplete
							url="/sources/autocomplete"
							min="3"
							param="term"
							event-send="sourceSelect"
							label="label_html"
							placeholder="Type for search..."
							display="label">
						</autocomplete>
						<button type="button" class="normal-input" v-if="!citation" @click="setDefaultSource()">Use default source</button>
					</div>
					<hr>
					<div v-if="citation != undefined">
						<div class="flex-separate middle">
							<p>{{ citation.source.object_tag }}</p><span class="circle-button btn-delete" @click="removeSource(taxon.origin_citation.id)"></span>
						</div>
					</div>
				</div>
				<div v-if="show == 'verbatim'">
			        <div class="field separate-top">
			          <label>Verbatim author</label><br>
			          <verbatim-author></verbatim-author>
			        </div>
			        <div class="fields">
			          <label>Verbatim year</label><br>
			          <verbatim-year></verbatim-year>
			        </div>
		        </div>
		        <div v-if="show == 'person'">
		        	<role-picker @create="updateTaxonName" @delete="updateTaxonName" v-model="roles" @sortable="updateTaxonName" @update="updatePersons" role-type="TaxonNameAuthor"></role-picker>
		        </div>
			</div>
		</div>
	</form>
</template>

<script>

  	const GetterNames = require('../store/getters/getters').GetterNames;
	const MutationNames = require('../store/mutations/mutations').MutationNames;
	const ActionNames = require('../store/actions/actions').ActionNames;

	const verbatimAuthor = require('./verbatimAuthor.vue');
	const verbatimYear = require('./verbatimYear.vue');
 	const autocomplete = require('../../../components/autocomplete.vue');
  	const rolePicker = require('../../../components/role_picker.vue');
	const expand = require('./expand.vue');

	export default {
		components: {
			autocomplete,
			verbatimAuthor,
			verbatimYear,
			rolePicker,
			expand
		},
		computed: {
			citation() {
				return this.$store.getters[GetterNames.GetCitation]
			},
			taxon() {
				return this.$store.getters[GetterNames.GetTaxon]
			},
			verbatimFieldsWithData() {
				return (this.taxon.verbatim_author || this.taxon.year_of_publication)
			},
			roles: {
				get() {
					if(this.$store.getters[GetterNames.GetRoles] == undefined) return [];
					return this.$store.getters[GetterNames.GetRoles].sort(function(a, b) {
						return (a.position - b.position)
					});
				},
				set(value) {
					this.$store.commit(MutationNames.SetRoles, value)
				}
			}
		},
		data: function() {
			return {
				show: 'source',
				expanded: true
			}
		},
		mounted: function() {
			this.$on('sourceSelect', function(value) {
				this.$store.dispatch(ActionNames.ChangeTaxonSource, value.id)
			});
		},
		watch: {
			taxon: function(newVal, oldVal) {
				if(oldVal.id == undefined) {
					this.setDefaultSource()
				}
			}
		},
		methods: {
			setDefaultSource: function() {
				var that = this;
				setTimeout(function () {
					var sourceId = document.querySelector('[data-pinboard-section="Sources"] [data-insert="true"]').dataset.pinboardObjectId;
					if(sourceId && that.citation == undefined) {
						that.$store.dispatch(ActionNames.ChangeTaxonSource, sourceId)
					}
				}, 500);
			},
			getVerbatimCount: function() {
				var author = (taxon.year_of_publication && taxon.year_of_publication.length ? taxon.year_of_publication.length : 0)
				return taxon.year_of_publication
			},
			updatePersons: function(list) {
				this.$store.commit(MutationNames.SetRoles, list)
			},
			removeSource: function(id) {
				this.$store.dispatch(ActionNames.RemoveSource, id);
			},
		    updateTaxonName: function() {
		        var taxon_name = {
		          taxon_name: {
		          	id: this.taxon.id,
				    roles_attributes: this.taxon.roles_attributes,
		            type: 'Protonym'
		          }
		        }
		      	this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon);
			}
		}
	};
</script>