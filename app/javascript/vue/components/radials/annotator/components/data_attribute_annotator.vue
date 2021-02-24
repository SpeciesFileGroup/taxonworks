<template>
  <div class="data_attribute_annotator">
    <div v-if="preferences">
      <div class="switch-radio separate-bottom">
        <template v-for="item, index in tabOptions">
          <template v-if="item == 'new' || preferences[item].length && preferences[item].find(predicate => { return !predicateAlreadyCreated(predicate) })">
            <input
              v-model="view"
              :value="item"
              :id="`switch-picker-${index}`"
              name="switch-picker-options"
              type="radio"
              class="normal-input button-active"
            >
            <label :for="`switch-picker-${index}`" class="capitalize">{{ item }}</label>
          </template>
        </template>
      </div>
    </div>

    <template v-if="preferences && view != 'new'">
      <div class="field separate-bottom annotator-buttons-list">
        <template v-for="predicate in preferences[view]">
          <button
            v-if="!predicateAlreadyCreated(predicate)"
            @click="data_attribute.controlled_vocabulary_term_id = predicate.id"
            type="button"
            :key="predicate.id"
            class="button normal-input margin-small-left margin-small-bottom"
            :class="{ 'button-default': (data_attribute.controlled_vocabulary_term_id != predicate.id)}">
            {{ predicate.name }}
          </button>
        </template>
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
      param="term"/>
    <textarea class="separate-bottom" placeholder="Value" v-model="data_attribute.value"/>
    <div v-if="!data_attribute.hasOwnProperty('id')">
      <button 
        @click="createNew()"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        type="button">Create</button>
    </div>
    <div v-else>
      <button @click="updateData()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Update</button>
      <button @click="data_attribute = newData()" :disabled="!validateFields" class="button button-default normal-input separate-bottom" type="button">New</button>
    </div>
    <table-list
      :list="list"
      :header="['Name', 'Value', '']"
      :attributes="['predicate_name', 'value']"
      :edit="true"
      target-citations="data_attributes"
      @edit="data_attribute = $event"
      @delete="removeItem"/>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import AnnotatorExtend from '../components/annotatorExtend.js'
import Autocomplete from 'components/autocomplete.vue'
import TableList from './shared/tableList'
import ListItems from './shared/listItems'

export default {
  mixins: [CRUD, AnnotatorExtend],
  components: {
    Autocomplete,
    TableList,
    ListItems
  },
  computed: {
    validateFields () {
      return (this.data_attribute.controlled_vocabulary_term_id &&
						this.data_attribute.value.length)
    }
  },
  data: function () {
    return {
      view: 'new',
      tabOptions: ['quick', 'recent', 'pinboard', 'all', 'new'],
      preferences: undefined,
      data_attribute: this.newData()
    }
  },
  mounted: function () {
    var that = this
    this.loadTabList('Predicate')
  },
  methods: {
    newData () {
      return {
        type: 'InternalAttribute',
        controlled_vocabulary_term_id: undefined,
        value: '',
        annotated_global_entity: decodeURIComponent(this.globalId)
      }
    },
    createNew () {
      this.create('/data_attributes', { data_attribute: this.data_attribute }).then(response => {
        this.list.push(response.body)
        this.data_attribute = this.newData()
      })
    },
    updateData () {
      this.update(`/data_attributes/${this.data_attribute.id}`, { data_attribute: this.data_attribute }).then(response => {
        this.$set(this.list, this.list.findIndex(element => element.id == this.data_attribute.id), response.body)
        this.data_attribute = this.newData()
      })
    },
    predicateAlreadyCreated (predicate) {
      return this.list.find(item => { return predicate.id == item.controlled_vocabulary_term_id })
    },
    loadTabList (type) {
      let tabList
      let allList
      let promises = []
      let that = this

      promises.push(this.getList(`/predicates/select_options?klass=${this.objectType}`).then(response => {
        tabList = response.body
      }))
      promises.push(this.getList(`/controlled_vocabulary_terms.json?type[]=${type}`).then(response => {
        allList = response.body
      }))

      Promise.all(promises).then(() => {
        tabList['all'] = allList
        that.preferences = tabList
      })
    }
  }
}
</script>
<style lang="scss">
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
