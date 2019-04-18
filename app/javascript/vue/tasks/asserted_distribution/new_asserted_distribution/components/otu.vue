<template>
    <fieldset>
      <legend>Otu</legend>
      <smart-selector 
        name="otu"
        class="separate-bottom"
        v-model="view"
        :options="options"/>
      <div v-if="isViewSearch">
        <otu-picker
          :clear-after="true"
          @getItem="sendItem"/>
      </div>
      <ul
        v-else
        class="no_bullets">
        <li
          v-for="item in lists[view]">
          <label
            @click="sendItem(item)">
            <input
              type="radio"
              name="otu"
              :checked="item.id == value">
            <span v-html="item.object_tag"/>
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

import SmartSelector from 'components/switch'
import OtuPicker from 'components/otu/otu_picker/otu_picker'
import { GetOtuSmartSelector } from '../request/resources.js'
import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector'
import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption'

export default {
  components: {
    SmartSelector,
    OtuPicker
  },
  props: {
    value: {}
  },
  computed: {
    isViewSearch() {
      return this.view == 'search/new'
    }
  },
  data() {
    return {
      otu: undefined,
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
      GetOtuSmartSelector().then(response => {
        this.lists = response.body
        this.options = OrderSmartSelector(Object.keys(response.body))
        let newView = SelectFirstSmartOption(this.lists, this.options)
        this.options.push('search/new')
        this.view = (newView ? newView : 'search/new')
      })
    },
    setSelected(item) {
      this.selected = item.hasOwnProperty('label') ? item.label : item.object_tag
    }
  }
}
</script>

<style scoped>
  li {
    margin-bottom: 8px;
  }
</style>