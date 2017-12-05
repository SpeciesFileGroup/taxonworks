<template>
	<div class="data_attribute_annotator">
		<div class="switch-radio separate-bottom" v-if="preferences">
			<template v-for="item, key, index in preferences">
				<input 
					v-model="view"
					:value="key"
					:id="`switch-picker-${index}`" 
					name="switch-picker-options"
					type="radio"
					class="normal-input button-active" 
				/>
				<label :for="`switch-picker-${index}`" class="capitalize">{{ key }}</label>
			</template>
			<input 
				v-model="view"
				value="new"
				id="switch-picker-new" 
				name="switch-picker-options"
				type="radio"
				class="normal-input button-active" 
			/>
			<label :for="`switch-picker-new`" class="capitalize">New</label>
		</div>

		<template v-if="view && view != 'new'">
			<div class="field separate-bottom">
				<button v-for="predicate in preferences[view]" 
					@click="data_attribute.controlled_vocabulary_term_id = predicate.id" 
					type="button" :class="{ 'button-default': (data_attribute.controlled_vocabulary_term_id == predicate.id)}" class="normal-input">{{ predicate.name }}
				</button>
			</div>
		</template>

	    <autocomplete
	      v-if="!data_attribute.hasOwnProperty('id') && view && view == 'new'"
	      url="/predicates/autocomplete"
	      label="label"
	      min="2"
	      placeholder="Select a predicate"
	      @getItem="data_attribute.controlled_vocabulary_term_id = $event.id"
	      class="separate-bottom"
	      param="term">
	    </autocomplete>
	    <textarea class="separate-bottom" placeholder="Value" v-model="data_attribute.value"></textarea>
	    <div v-if="!data_attribute.hasOwnProperty('id')">
	    	<button @click="createNew()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Create</button>
		</div>
		<div v-else>
	    	<button @click="updateData()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Update</button>
	    	<button @click="data_attribute = newData()" :disabled="!validateFields" class="button button-default normal-input separate-bottom" type="button">New</button>
		</div>
		<table-list :list="list" :header="['Name', 'Value', '']" :attributes="['predicate_name', 'value']" :edit="true"  @edit="data_attribute = $event" @delete="removeItem"></table-list>
	</div>
</template>
<script>

	import CRUD from '../request/crud.js';
	import annotatorExtend from '../components/annotatorExtend.js';
	import autocomplete from '../../autocomplete.vue';
	import tableList from '../../table_list.vue';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			autocomplete,
			tableList,
			displayList
		},
		computed: {
			validateFields() {
				return (this.data_attribute.controlled_vocabulary_term_id &&
						this.data_attribute.value.length)
			},
		},
		data: function() {
			return {
				view: 'new',
				preferences: undefined,
				data_attribute: this.newData()
			}
		},
		mounted: function() {
			var that = this;
			this.getList(`/predicates/select_options?klass=${this.objectType}`).then(response => {
				this.preferences = response.body;
			})
		},
		methods: {
			newData() {
				return {
					type: 'InternalAttribute',
                    controlled_vocabulary_term_id: undefined,
                    value: '',
                    annotated_global_entity: decodeURIComponent(this.globalId)
                }
			},
			createNew() {
				this.create('/data_attributes', { data_attribute: this.data_attribute }).then(response => {
					this.list.push(response.body);
					this.data_attribute = this.newData();
				});
			},
			updateData() {
				this.update(`/data_attributes/${this.data_attribute.id}`, { data_attribute: this.data_attribute }).then(response => {
					this.$set(this.list, this.list.findIndex(element => element.id == this.data_attribute.id), response.body);
					this.data_attribute = this.newData();
				});		
			}
		}
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.data_attribute_annotator { 
		button {
			min-width: 100px;
		}
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
		.vue-autocomplete-input {
			width: 100%;
		}
	}
}
</style>