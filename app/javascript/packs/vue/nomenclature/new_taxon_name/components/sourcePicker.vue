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
				    <button class="normal-input" @click="show = 'source'" type="button">Source</button>
				    <button class="normal-input" @click="show = 'verbatim'" type="button">Verbatim</button>
				    <button class="normal-input" @click="show = 'person'" type="button">Person</button>
			    </div>
			    <div v-if="show == 'source'">
					<autocomplete
						url="/sources/autocomplete"
						min="3"
						param="term"
						event-send="sourceSelect"
						label="label_html"
						placeholder="Type for search..."
						display="label">
					</autocomplete>
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
		        	<role-picker v-model="roles" type="TaxonNameAuthor"></role-picker>
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
			roles: {
				get() {
					return this.$store.getters[GetterNames.GetRoles]
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
		methods: {
			removeSource: function(id) {
				this.$store.dispatch(ActionNames.RemoveSource, id);
			}
		}
	};
</script>