<template>
	<div class="identifier_annotator">
		<div>
			<div v-if="namespace">

				<div class="separate-bottom">
					<span class="capitalize">{{ namespace }}</span>
					<button type="button" @click="reset()">Change</button>
				</div>

				<div v-if="namespace != 'unknown'" class="switch-radio">
					<template v-for="item, index in barList">
						<input 
							v-model="display"
							:value="item"
							:id="`alternate_values-picker-${index}`" 
							name="alternate_values-picker-options"
							type="radio"
							class="normal-input button-active" 
						/>
						<label :for="`alternate_values-picker-${index}`" class="capitalize">{{ item }}</label>
					</template>
				</div>

		        <div class="separate-bottom separate-top">

					<ul v-show="namespace != 'unknown'" class="no_bullets">
						<li v-for="item in typeList[namespace].common">
							<label class="capitalize">
								<input type="radio" v-model="identifier.type" v-bind:value="item">
								{{ typeList[namespace].all[item].label }}
							</label>
						</li>
					</ul>

					<modal class="transparent-modal" v-if="display == 'show all'" @close="display = 'common'">
						<h3 slot="header">Types</h3>
						<div slot="body">
							<ul>
								<li class="modal-list-item" v-for="item, key in typeList[namespace].all">
									<button type="button" :value="key" @click="identifier.type = key, display = 'common'" class="button button-default normal-input modal-button capitalize"> 
									{{ item.label }} 
									</button>
								</li>
							</ul>
						</div>
					</modal>					
				</div>				

				<p v-if="identifier.type" class="capitalize">Type: {{ typeList[namespace].all[identifier.type].label }}</p>

				<div class="field" v-if="namespace == 'local'">
				    <autocomplete
				      url="/namespaces/autocomplete"
				      label="label"
				      min="2"
				      placeholder="Namespaces"
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
		<table-list :list="list" :header="['Identifier', 'Type', '']" :attributes="['cached', 'type_name']" @edit="data_attribute = $event" @delete="removeItem"></table-list>
	</div>
</template>
<script>

	import CRUD from '../request/crud.js';
	import annotatorExtend from '../components/annotatorExtend.js';
	import autocomplete from '../../autocomplete.vue';
	import modal from '../../modal.vue';
	import tableList from '../../table_list.vue';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			autocomplete,
			tableList,
			modal
		},
		computed: {
			validateFields() {
				return this.identifier.identifier && 
						(this.identifier.type) &&
						((this.namespace == 'local' && this.identifier.namespace_id) || (this.namespace != 'local'))
			},
		},
		data: function() {
			return {
				showAll: false,
				display: 'common',
				barList: ['common', 'show all'],
				identifier: this.newIdentifier(),
				namespace: undefined,
				typeList: []
			}
		},
		watch: {
			'namespace': function(newVal) {
				if(newVal == 'unknown') {
					this.identifier.type = this.typeList[newVal].common[0];
				}
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
				return result;
			},
			newIdentifier() {
				return {
                    type: undefined,
                    namespace_id: undefined,
                    identifier: undefined,
                    annotated_global_entity: decodeURIComponent(this.globalId)
                }
			},
			createNew() {
				this.create('/identifiers', { identifier: this.identifier }).then(response => {
					this.list.push(response.body);
					this.namespace = undefined;
					this.identifier = this.newIdentifier();
				});
			},
			reset() {
				this.identifier = this.newIdentifier();
				this.namespace = undefined;
				this.display = 'common';
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