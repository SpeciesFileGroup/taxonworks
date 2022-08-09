<template>
  <fieldset>
    <legend>Data attributes</legend>
    <switch-component
      class="margin-medium-bottom"
      v-model="view"
      :options="tabs"/>
    <template v-if="!selected">
      <template v-if="lists && view == 'all'">
        <div class="flex-wrap-row margin-medium-top">
          <button
            v-for="attr in lists['all']"
            :key="attr.id"
            @click="setDataAttribute(attr.id, attr.name)"
            class="button normal-input margin-small-right margin-small-bottom"
            :class="{ 'button-default': dataAttribute.controlled_vocabulary_term_id != attr.id }"
            type="button">
            {{ attr.name }}
          </button>
        </div>
      </template>
      <autocomplete
        v-else
        url="/predicates/autocomplete"
        label="label"
        min="2"
        placeholder="Select a predicate"
        @getItem="setDataAttribute($event.id, $event.label)"
        class="separate-bottom"
        param="term"/>
    </template>
    <div
      v-else
      class="horizontal-left-content">
      <span v-html="selected"/>
      <span
        class="button circle-button btn-undo button-default"
        @click="selected = undefined; dataAttribute.controlled_vocabulary_term_id = undefined"/>
    </div>
    <label>Value</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="dataAttribute.value"></textarea>
    <button
      class="button normal-input button-default margin-medium-top"
      @click="addDataAttribute"
      :disabled="!validateFields"
      type="button">
      Add
    </button>
    <table-list
      v-if="dataAttributes.length"
      :list="dataAttributes"
      :header="['Predicate', 'Value', 'Remove']"
      :delete-warning="false"
      :annotator="false"
      row-key="controlled_vocabulary_term_id"
      @delete="removeDataAttribute"
      :attributes="['label', 'value']"/>
  </fieldset>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import TableList from 'components/table_list'
import SwitchComponent from 'components/switch'

import AjaxCall from 'helpers/ajaxCall.js'

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    SwitchComponent,
    TableList,
    Autocomplete
  },

  computed: {
    dataAttributes: {
      get () {
        return this.$store.getters[GetterNames.GetDataAttributes]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDataAttributes, value)
      }
    },
    validateFields () {
      return this.dataAttribute.controlled_vocabulary_term_id && this.dataAttribute.value
    }
  },

  data () {
    return {
      tabs: ['all', 'search'],
      view: 'search',
      tabList: {},
      lists: undefined,
      dataAttribute: this.newDataAttribute(),
      selected: undefined
    }
  },

  mounted () {
    this.loadTabList()
  },

  methods: {
    loadTabList () {
      const promises = []
      let tabList
      let allList

      promises.push(AjaxCall('get', '/predicates/select_options?klass=CollectionObject').then(response => {
        tabList = response.body
      }))
      promises.push(AjaxCall('get', '/controlled_vocabulary_terms.json?type[]=Predicate').then(response => {
        allList = response.body
      }))

      Promise.all(promises).then(() => {
        tabList['all'] = allList
        this.lists = tabList
      })
    },

    newDataAttribute () {
      return {
        label: undefined,
        controlled_vocabulary_term_id: undefined,
        type: 'InternalAttribute',
        value: undefined
      }
    },

    addDataAttribute () {
      this.$store.commit(MutationNames.AddDataAttribute, this.dataAttribute)
      this.dataAttribute = this.newDataAttribute()
    },

    setDataAttribute (id, label) {
      this.selected = label
      this.dataAttribute.label = label
      this.dataAttribute.controlled_vocabulary_term_id = id
    }
  }
}
</script>
