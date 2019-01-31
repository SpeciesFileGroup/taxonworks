<template>
  <div class="panel content">
    <h2>Depic some</h2>
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
          :options="options"/>
        <autocomplete
          v-if="view == 'search'"
          :disabled="!selectedType"
          :url="selectedType.url"
          param="term"/>
      </div>
    </div>
    <table-list
      :list="selectedObjects"
      :header="['Objects', 'Remove']"
      :attributes="['object_tag']"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import TableList from 'components/table_list'
import Autocomplete from 'components/autocomplete'

import { GetOtuSmartSelector, GetCollectingEventSmartSelector, GetCollectionObjectSmartSelector } from '../request/resources.js'

export default {
  components: {
    SmartSelector,
    TableList,
    Autocomplete
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
    setSelected(value) {
      this.selectedType = value
    },
    getSmartSelector(type) {
      switch (type) {
        case 'Otu':
          GetOtuSmartSelector().then(response => {
            this.options = Object.keys(response.body)
            this.lists = response.body
          })
          break;
        case 'CollectionObject':
          GetCollectionObjectSmartSelector().then(response => {
            this.options = Object.keys(response.body)
            this.lists = response.body
          })
          break;
        case 'CollectingEvent':
          GetCollectingEventSmartSelector().then(response => {
            this.options = Object.keys(response.body)
            this.lists = response.body
          })
          break;
      }

    }
  }
}
</script>