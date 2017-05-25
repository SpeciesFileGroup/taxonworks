<template>
	<div id="cite_otus">
		<div class="flexbox">
			<div>
				<div class="flexbox">
					<div v-if="!disabled" class="panel item1 flex-wrap-row middle" id="delete-citation">
						<remove-citation></remove-citation>
					</div>  
					<div class="item item1 separate-right">
						<div>
							<div class="panel">
								<div id="source-picker" class="flex-separate horizontal-center-content content">
									<div class="content full_width">
										<div v-if="source">
											<p v-html="source.object_tag"></p>
										</div>
									</div>
									<source-picker></source-picker>
								</div>
							</div>
							<div class="panel">
								<div id="otu-picker" class="horizontal-left-content content">
									<div class="content full_width">
										<div v-if="otu">
											<h3 v-html="otu.object_tag"></h3>
										</div>
									</div>
									<otu-picker></otu-picker>
								</div>   
							</div>
						</div>
						<div class="panel" v-if="!disabled">
							<topics-checklist></topics-checklist>
						</div>
					</div>
				</div>
			</div>
			<div id="recent_list" class="slide-panel slide-left slide-recent item item2 separate-left slide-recent" data-panel-position="relative" data-panel-open="true" data-panel-name="recent_list">
				<div class="slide-panel-header flex-separate"><span>Recent</span></div>
				<div class="slide-panel-content">
					<source-citations></source-citations>
					<otu-citations></otu-citations>         
				</div>    
			</div>
		</div>
	</div>
</template>
<script>

	const GetterNames = require('./store/getters/getters').GetterNames;
	const MutationNames = require('./store/mutations/mutations').MutationNames;

	const removeCitation = require('./components/removeCitation.vue');
	const otuPicker = require('./components/otuPicker.vue');
	const otuCitations = require('./components/otuCitations.vue');
	const topicsChecklist = require('./components/topicsChecklist.vue');
	const sourceCitations = require('./components/sourceCitations.vue');
	const sourcePicker = require('./components/sourcePicker.vue');

	export default {
		components: {
			removeCitation,
			otuPicker,
			sourcePicker,
			otuCitations,
			topicsChecklist,
			sourceCitations,
		},
		computed: {
			otu() {
				return this.$store.getters[GetterNames.GetOtuSelected]
			},
			source() {
				return this.$store.getters[GetterNames.GetSourceSelected]
			},        
			disabled() {
				return this.$store.getters[GetterNames.ObjectsSelected]
			}      
		},

		watch: {
			otu: function(val, oldVal) {
				if (val !== oldVal) { 
					if(val != undefined)
						this.loadOtuCitations();
					if(!this.disabled) {
						this.loadCitations();              
					}
				}
			},
			source: function(val, oldVal) {
				if (val !== oldVal) { 
					if(val != undefined)
						this.loadSourceCitations();            
					if(!this.disabled) {
						this.loadCitations();
					}
				}
			}
		},         

		methods: {
			loadSourceCitations: function() {
				var that = this,
				filterUrl = `/citations/filter?source_id=${that.$store.getters[GetterNames.GetSourceSelected].id}&citation_object_type=Otu`;

				this.$http.get(filterUrl).then(response => {
					if(response.body.length) {
						that.$store.commit(MutationNames.SetSourceCitationsList, response.body);
					}
				})
			},

			loadOtuCitations: function() {
				var that = this,
				filterUrl = `/citations/filter?citation_object_type=Otu&citation_object_id=${that.$store.getters[GetterNames.GetOtuSelected].id}`;

				this.$http.get(filterUrl).then(response => {
					if(response.body.length) {
						that.$store.commit(MutationNames.SetOtuCitationsList, response.body);
					}
				})
			},


			loadCitations: function() {
				var that = this,
				filterUrl = `/citations/filter?source_id=${that.$store.getters[GetterNames.GetSourceSelected].id}&citation_object_type=Otu&citation_object_id=${that.$store.getters[GetterNames.GetOtuSelected].id}`;

				this.$http.get('/otus/' + that.$store.getters[GetterNames.GetOtuSelected] + '/citations').then(response => {
					that.$store.commit(MutationNames.SetCitationsList, response.body);
				}); 

				this.$http.get(filterUrl).then(response => {
					if(response.body.length) {
						that.$store.commit(MutationNames.SetCurrentCitation, response.body[0]);
						that.$store.commit(MutationNames.AddCitation, response.body[0]);
						that.$store.commit(MutationNames.SetTopicsSelected, response.body[0].citation_topics);            
					}
					else {
						var citation = {
							citation_object_type: 'Otu',  
							citation_object_id: that.$store.getters[GetterNames.GetOtuSelected].id,          
							source_id: that.$store.getters[GetterNames.GetSourceSelected].id
						}

						this.$http.post('/citations', citation).then( response => {
							that.$store.commit(MutationNames.SetCurrentCitation, response.body);
							that.$store.commit(MutationNames.AddCitation, response.body);
							that.$store.commit(MutationNames.AddToSourceList,response.body);
							that.$store.commit(MutationNames.AddToOtuList,response.body);
							that.$store.commit(MutationNames.SetTopicsSelected, response.body.citation_topics); 
						})            
					}
				});            
			}
		},        

		beforeCreate: function() {
			this.$http.get('/topics.json').then(response => {
				this.$store.commit(MutationNames.SetTopicsList, response.body);
			});
		},
	}
</script>