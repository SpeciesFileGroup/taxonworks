<template>
	<div class="identifier_annotator">
		<select v-model="identifier.type" class="normal-input">
			<option v-for="option, key in typeList" :value="key">
				{{ option.type }}
			</option>
		</select>
	    <autocomplete
	      url="/namespaces/autocomplete"
	      label="label"
	      min="2"
	      placeholder="Confidence level"
	      @getItem="identifier.namespace_id = $event.id"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <div class="field">
	    	<input class="normal-input" placeholder="Identifier" type="text" v-model="identifier.identifier"/>
		</div>
	    <button @click="createNew()" :disabled="!validateFields" class="button normal-input button-submit separate-bottom" type="button">Create</button>
	    <display-list label="object_tag" :list="list" @delete="removeItem" class="list"></display-list>
	</div>
</template>
<script>

	import CRUD from '../request/crud.js';
	import annotatorExtend from '../components/annotatorExtend.js';
	import autocomplete from '../../autocomplete.vue';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			autocomplete,
			displayList
		},
		computed: {
			validateFields() {
				return (this.identifier.namespace_id &&
						this.identifier.identifier)
			},
		},
		data: function() {
			return {
				identifier: this.newIdentifier(),
				typeList: {
					'Identifier::Unknown': {
						type: 'Unknown'
					}
				}
			}
		},
		methods: {
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
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
		.vue-autocomplete-input, .input {
			width: 100%;
		}
	}
}
</style>