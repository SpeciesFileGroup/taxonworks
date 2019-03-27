<template>
  <fieldset>
    <legend>Geographic area</legend>
    <smart-selector 
      name="geographic"
      class="separate-bottom"
      v-model="view"
      :options="options"/>
    <div v-if="isViewSearch">
      <autocomplete
        url="/geographic_areas/autocomplete"
        label="label_html"
        param="term"
        ref="autocomplete"
        placeholder="Select a geographic area"
        :clear-after="true"
        display="label"
        @getItem="sendItem"/>
    </div>
    <ul
      v-else
      class="no_bullets">
      <li
        v-for="item in lists[view]"
        :key="item.id">
        <label
          @click="sendItem(item)">
          <input
            type="radio"
            name="geo"
            :checked="item.id == value">
          {{ item.name }}
        </label>
      </li>
    </ul>
    <template v-if="selected">
      <p>
        <span data-icon="ok"/>
        <span v-html="selected"/>
      </p>
    </template>
  </fieldset>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import SmartSelector from 'components/switch'
import { GetGeographicAreaSmartSelector } from '../request/resources.js'
import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector'
import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption'

export default {
  components: {
    SmartSelector,
    Autocomplete
  },
  props: {
    value: {}
  },
  computed: {
    isViewSearch() {
      return this.view == 'search'
    }
  },
  data() {
    return {
      options: [],
      lists: [],
      view: undefined,
      selected: undefined
    }
  },
  watch: {
    value(newVal) {
      if(newVal == undefined)
        this.selected = undefined
    }
  },
  mounted() {
    this.loadSmartSelector()
  },
  methods: {
    sendItem(item) {
      this.setSelected(item)
      this.$emit('input', item.id)
    },
    loadSmartSelector() {
      GetGeographicAreaSmartSelector().then(response => {
        this.lists = response.body
        this.options = OrderSmartSelector(Object.keys(response.body))
        let newView = SelectFirstSmartOption(this.lists, this.options)
        this.options.push('search')
        this.view = (newView ? newView : 'search')
      })
    },
    setSelected(item) {
      this.selected = item.hasOwnProperty('label') ? item.label : item.name
    }
  }
}
</script>