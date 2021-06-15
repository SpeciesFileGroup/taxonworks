<template>
  <div class="data_attribute_annotator">
    <div v-if="preferences">
      <div class="switch-radio separate-bottom">
        <template v-for="item, index in tabOptions">
          <template v-if="item == 'new' || preferences[item].length && preferences[item].find(predicate => !predicateAlreadyCreated(predicate))">
            <input
              v-model="view"
              :value="item"
              :id="`switch-picker-${index}`"
              name="switch-picker-options"
              type="radio"
              class="normal-input button-active"
            >
            <label
              :for="`switch-picker-${index}`"
              class="capitalize">{{ item }}</label>
          </template>
        </template>
      </div>
    </div>

    <template v-if="preferences && view != 'new'">
      <div class="field separate-bottom annotator-buttons-list">
        <template
          v-for="predicate in preferences[view]"
          :key="predicate.id">
          <button
            v-if="!predicateAlreadyCreated(predicate)"
            @click="data_attribute.controlled_vocabulary_term_id = predicate.id"
            type="button"
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
    <textarea
      v-model="data_attribute.value"
      class="separate-bottom"
      placeholder="Value"
    />
    <div v-if="!data_attribute.hasOwnProperty('id')">
      <button 
        @click="createNew()"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        type="button">Create</button>
    </div>
    <div v-else>
      <button
        @click="updateData()"
        :disabled="!validateFields"
        class="button button-submit normal-input separate-bottom"
        type="button">Update</button>
      <button
        @click="data_attribute = newData()"
        :disabled="!validateFields"
        class="button button-default normal-input separate-bottom"
        type="button">New</button>
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
import Autocomplete from 'components/ui/Autocomplete.vue'
import TableList from './shared/tableList'

export default {
  mixins: [CRUD, AnnotatorExtend],
  components: {
    Autocomplete,
    TableList
  },
  computed: {
    validateFields () {
      return (this.data_attribute.controlled_vocabulary_term_id &&
              this.data_attribute.value.length)
    }
  },

  data () {
    return {
      view: 'new',
      tabOptions: ['quick', 'recent', 'pinboard', 'all', 'new'],
      preferences: undefined,
      data_attribute: this.newData()
    }
  },

  mounted () {
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
        const index = this.list.findIndex(element => element.id === this.data_attribute.id)

        this.list[index] = response.body
        this.data_attribute = this.newData()
      })
    },

    predicateAlreadyCreated (predicate) {
      return this.list.find(item => predicate.id === item.controlled_vocabulary_term_id)
    },

    loadTabList (type) {
      const promises = []
      let tabList
      let allList

      promises.push(this.getList(`/predicates/select_options?klass=${this.objectType}`).then(response => {
        tabList = response.body
      }))
      promises.push(this.getList(`/controlled_vocabulary_terms.json?type[]=${type}`).then(response => {
        allList = response.body
      }))

      Promise.all(promises).then(() => {
        tabList['all'] = allList
        this.preferences = tabList
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
