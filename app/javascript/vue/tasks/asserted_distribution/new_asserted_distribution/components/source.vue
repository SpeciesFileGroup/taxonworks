<template>
  <fieldset>
    <legend>Source</legend>
    <smart-selector 
      name="source"
      class="separate-bottom"
      v-model="view"
      :options="options"/>
    <div class="separate-bottom flex-separate middle">
      <label>
        <input
          type="checkbox"
          v-model="value.is_original">
        Is original
      </label>
      <label>
        Pages: 
        <input
          class="pages"
          v-model="value.pages"
          placeholder="Pages"
          type="text">
      </label>
    </div>
    <div v-if="isViewSearch">
      <autocomplete
        url="/sources/autocomplete"
        label="label_html"
        placeholder="Select a source"
        ref="autocomplete"
        :clear-after="true"
        param="term"
        display="label"
        @getItem="sendItem"/>
    </div>
    <div v-else>
      <ul
        class="no_bullets">
        <li v-for="item in lists[view]">
          <label @click="sendItem(item)">
            <input
              name="source"
              type="radio"
              :value="item.id"
              :checked="item.id == value.source_id">
            <span v-html="item.object_tag"/>
          </label>
        </li>
      </ul>
    </div>
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
import { GetSourceSmartSelector } from '../request/resources.js'
import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector'
import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption'

export default {
  components: {
    SmartSelector,
    Autocomplete
  },
  props: {
    value: {
      type: Object,
      required: true
    }
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
      selected: undefined,
      view: undefined,
    }
  },
  watch: {
    value: {
      handler(newVal) {
        if(newVal.source_id == undefined)
          this.selected = undefined
      },
    deep: true
    }
  },
  mounted() {
    this.loadSmartSelector()
  },
  methods: {
    sendItem(item) {
      let newVal = this.value
      newVal.source_id = item.id
      this.selected = item.hasOwnProperty('label') ? item.label : item.object_tag
      this.$emit('input', newVal)
    },
    loadSmartSelector() {
      GetSourceSmartSelector().then(response => {
        this.lists = response.body
        this.options = OrderSmartSelector(Object.keys(response.body))
        let newView = SelectFirstSmartOption(this.lists, this.options)
        this.options.push('search')
        this.view = (newView ? newView : 'search')
      })
    },
    setSelected(item) {
      this.selected = item.hasOwnProperty('label') ? item.label : item.object_tag
    }
  }
}
</script>

<style scoped>
  .pages {
    widows: 80px;
  }
</style>

