<template>
  <div class="panel content">
    <h2>Depict some</h2>
    <div class="flex-separate align-start">
      <ul class="no_bullets">
        <li
          v-for="objectType in objectTypes"
          :key="objectType.key">
          <label
            @click="setSelected(objectType)">
            <input
              name="depicsome"
              :value="objectType.key"
              type="radio">
            {{ objectType.label }}
          </label>
        </li>
      </ul>
      <div>
        <smart-selector
          v-model="view"
          class="separate-bottom"
          :options="options"/>
        <template v-if="view == 'search'">
          <autocomplete
            v-if="selectedType.key != 'Otu'"
            :disabled="!selectedType"
            :url="selectedType.url"
            label="label_html"
            :placeholder="`Select a ${selectedType.label.toLowerCase()}`"
            :clear-after="true"
            @getItem="addToList"
            param="term"/>
          <otu-picker
            v-else
            :clear-after="true"
            @getItem="addToList"/>
        </template>
        <ul
          v-else
          class="no_bullets">
          <li
            v-for="item in lists[view]"
            :key="item.id">
            <label @click="addToList(item)">
              <input
                name="items-depic-some"
                :checked="checkIfExist(item)"
                type="radio">
              <span v-html="item.object_tag"/>
            </label>
          </li>
        </ul>
      </div>
    </div>
    <table-list
      :list="listCreated"
      :header="['Objects', 'Remove']"
      :annotator="false"
      @delete="removeItem"
      :attributes="['label']"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import TableList from 'components/table_list'
import Autocomplete from 'components/autocomplete'
import OtuPicker from 'components/otu/otu_picker/otu_picker'

import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector.js'
import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption.js'
import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'

import { GetOtuSmartSelector, GetCollectingEventSmartSelector, GetCollectionObjectSmartSelector } from '../request/resources.js'

export default {
  components: {
    SmartSelector,
    TableList,
    Autocomplete,
    OtuPicker
  },
  computed: {
    listCreated() {
      return this.$store.getters[GetterNames.GetObjectsForDepictions]
    }
  },
  data() {
    return {
      objectTypes: [
        {
          key: 'Otu',
          label: 'Otu',
          url: '/otus/autocomplete'
        },
        {
          key: 'CollectingEvent',
          label: 'Collecting event',
          url: '/collecting_events/autocomplete'
        },
        {
          key: 'CollectionObject',
          label: 'Collection object',
          url: '/collection_objects/autocomplete'
        }
      ],
      selectedType: undefined,
      options: [],
      lists: [],
      view: undefined,
      selectedObjects: []
    }
  },
  watch: {
    selectedType: {
      handler(newVal) {
        this.getSmartSelector(newVal.key)
      },
      deep: true
    }
  },
  mounted() {

  },
  methods: {
    removeItem(item) {
      this.$store.commit(MutationNames.RemoveObjectForDepictions, item)
    },
    checkIfExist(value) {
      if(this.listCreated.find(item => {
        return item.id == value.id && item.base_class == this.selectedType.key
      })) return true
      return false
    },
    addToList(item) {
      this.$store.commit(MutationNames.AddObjectForDepictions, 
      { 
        id: item.id, 
        label: item.hasOwnProperty('label') ? item.label : (this.selectedType.key == 'Otu'? item.object_label : item.object_tag),
        base_class: this.selectedType.key
      })
    },
    setSelected(value) {
      this.selectedType = value
    },
    getSmartSelector(type) {
      switch (type) {
        case 'Otu':
          GetOtuSmartSelector().then(response => {
            this.options = OrderSmartSelector(Object.keys(response.body))
            this.options.push('search')
            this.lists = response.body
            
            let selectedOption = SelectFirstSmartOption(this.lists, this.options)
            this.view = selectedOption ? selectedOption : 'search'
          })
          break;
        case 'CollectionObject':
          GetCollectionObjectSmartSelector().then(response => {
            this.options = OrderSmartSelector(Object.keys(response.body))
            this.options.push('search')
            this.lists = response.body

            let selectedOption = SelectFirstSmartOption(this.lists, this.options)
            this.view = selectedOption ? selectedOption : 'search'
          })
          break;
        case 'CollectingEvent':
          GetCollectingEventSmartSelector().then(response => {
            this.options = OrderSmartSelector(Object.keys(response.body))
            this.options.push('search')
            this.lists = response.body

            let selectedOption = SelectFirstSmartOption(this.lists, this.options)
            this.view = selectedOption ? selectedOption : 'search'
          })
          break;
      }
    }
  }
}
</script>