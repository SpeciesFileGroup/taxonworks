<template>
	<div class="identifier_annotator">
		<div>
			<div v-if="namespace">
		        <div class="switch-radio">
					<input name="identifier-picker-options" id="identifier-picker-common" checked type="radio" class="normal-input button-active" @click="display = 'common'"/>
					<label for="identifier-picker-common">Common</label>
					<input name="identifier-picker-options" id="identifier-picker-advanced" type="radio" class="normal-input" @click="display = 'advanced'"/>
					<label for="identifier-picker-advanced">Advanced</label>
					<input name="identifier-picker-options" id="identifier-picker-pinboard" type="radio" class="normal-input" @click="display = 'pinboard'"/>
					<label for="identifier-picker-pinboard">Pinboard</label>
					<input name="identifier-picker-options" id="identifier-picker-showall" type="radio" class="normal-input" @click="showAll = true"/>
					<label for="identifier-picker-showall">Show all</label>
		        </div>

		        <div class="separate-bottom separate-top">
					<ul v-if="display == 'common'" class="no_bullets">
						<li v-for="item in typeList[namespace].common">
							<label class="capitalize">
								<input type="radio" v-model="identifier.type" v-bind:value="item">
								{{ typeList[namespace].all[item].label }}
							</label>
						</li>
					</ul>

					<autocomplete v-if="display == 'advanced'"
						:arrayList="createArrayList(typeList[namespace].all)"
						label="label"
						min="1"
						time="0"
						placeholder="Search"
						@getItem="identifier.type = $event.value"
						param="term">
					</autocomplete> 

					<modal class="transparent-modal" v-if="showAll" @close="showAll = false">
						<h3 slot="header">Types</h3>
						<div slot="body">
							<ul>
								<li class="modal-list-item" v-for="item, key in typeList[namespace].all">
									<button type="button" :value="key" @click="identifier.type = key, showAll = false" class="button button-default normal-input modal-button capitalize"> 
									{{ item.label }} 
									</button>
								</li>
							</ul>
						</div>
					</modal>					
				</div>				

				<div class="field">
				    <autocomplete
				      url="/namespaces/autocomplete"
				      label="label"
				      min="2"
				      placeholder="Confidence level"
				      @getItem="identifier.namespace_id = $event.id"
				      param="term">
				    </autocomplete>
				</div>
			    <div class="field">
			    	<input class="normal-input identifier" placeholder="Identifier" type="text" v-model="identifier.identifier"/>
				</div>
			    <button @click="createNew()" :disabled="!validateFields" class="button normal-input button-submit separate-bottom" type="button">Create</button>
			</div>

			<div v-else class="field">
				<ul class="no_bullets">
					<li v-for="type, key in typeList">
						<label class="capitalize">
							<input type="radio" v-model="namespace" v-bind:value="key">
							{{ key }}
						</label>
					</li>
				</ul>
			</div>
		</div>
	    <display-list label="object_tag" :list="list" @delete="removeItem" class="list"></display-list>
	</div>
</template>
<script>

	import CRUD from '../request/crud.js';
	import annotatorExtend from '../components/annotatorExtend.js';
	import autocomplete from '../../autocomplete.vue';
	import modal from '../../modal.vue';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			autocomplete,
			displayList,
			modal
		},
		computed: {
			validateFields() {
				return (this.identifier.namespace_id &&
						this.identifier.identifier)
			},
		},
		data: function() {
			return {
				showAll: false,
				display: 'common',
				identifier: this.newIdentifier(),
				namespace: undefined,
				typeList: []
			}
		},
		mounted: function() {
			this.getList('/identifiers/identifier_types').then(response => {
				this.typeList = response.body;
			});
		},
		methods: {
			createArrayList(obj) {
				var result = Object.keys(obj).map(function(key) {
					return { 
						value: key, 
						label: obj[key].label
					};
				});
				console.log(result);
				return result;
			},
			newIdentifier() {
				return {
                    namespace_id: undefined,
                    type: 'Identifier::Unknown',
                    identifier: undefined,
                    annotated_global_entity: decodeURIComponent(this.globalId)
                }
			},
			createNew() {
				this.create('/identifiers', { identifier: this.identifier }).then(response => {
					this.list.push(response.body);
					this.identifier = this.newIdentifier();
				});
			}
		}
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.identifier_annotator { 
		button {
			min-width: 100px;
		}
		.identifier {
			width: 100%;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
		.vue-autocomplete-input, .input {
			width: 100%;
		}
		li {
			border-right: 0px;
			padding-left: 0px;
		}
		.modal-button {
			min-width: auto;
		}
		.modal-list-item {
			margin-top: 6px;
		}
	}
}
</style>