<template>
  <div>
    <smart-selector
      class="separate-bottom"
      :options="tabs"
      v-model="view"/>
    <div
      v-if="selected"
      class="horizontal-left-content">
      <span v-html="selectedLabel"></span>
      <span
        class="button circle-button btn-undo button-default"
        @click="selected = undefined"/>
    </div>
    <template v-else>
      <ul
        v-if="isList"
        class="no_bullets">
        <li
          v-for="item in lists[view]"
          :key="item.id">
          <label>
            <input
              type="radio"
              @click="sendSelected(item)">
            <span v-html="item.object_tag"/>
          </label>
        </li>
      </ul>
      <autocomplete
        v-else
        url="/sequences/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a sequence"
        @getItem="sendSelected"/>
    </template>
  </div>
</template>

<script>
import SmartSelector from 'components/switch'
import Autocomplete from 'components/autocomplete.vue'
import { GetSequenceSmartSelector } from '../../request/resources.js'
import OrderSmartSelector from 'helpers/smartSelector/orderSmartSelector.js'
import SelectFirstSmartOption from 'helpers/smartSelector/selectFirstSmartOption.js'
export default {
  props: {
    title: {
      type: String,
      required: true
    }
  },
  components: {
    SmartSelector,
    Autocomplete
  },
  computed: {
    isList() {
      return Object.keys(this.lists).includes(this.view)
    },
    selectedLabel() {
      return this.selected.hasOwnProperty('label_html') ? this.selected.label_html : this.selected.object_tag
    }
  },
  data () {
    return {
      lists: [],
      tabs: ['search'],
      view: undefined,
      selected: undefined
    }
  },
  mounted() {
    GetSequenceSmartSelector().then(response => {
      this.tabs = Object.keys(response.body)
      this.tabs.push('search')
      this.lists = response.body
    })
  },
  methods: {
    sendSelected(item) {
      this.selected = item
      this.$emit('selected', item)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%;
  }
</style>