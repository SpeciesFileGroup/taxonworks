<template>
  <div>
    <h2>Reverse Primer</h2>
    <smart-selector
      :options="tabs"
      v-model="view"/>
    <ul
      v-if="isList"
      class="no_bullets">
      <li
        v-for="item in lists[view]"
        :key="item.id">
        <label>
          <input type="radio">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
    <autocomplete
      v-else
      url="/sequences/autocomplete"
      param="term"
      placeholder="Search a sequence"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import Autocomplete from 'components/autocomplete.vue'
import { GetSequenceSmartSelector } from '../request/resources.js'

import OrderSmartSelector from '../../../../helpers/smartSelector/orderSmartSelector.js'
import SelectFirstSmartOption from '../../../../helpers/smartSelector/selectFirstSmartOption.js'

export default {
  components: {
    SmartSelector,
    Autocomplete
  },
  computed: {
    isList() {
      return Object.keys(this.lists).includes(this.view)
    }
  },
  data () {
    return {
      lists: [],
      tabs: [],
      view: undefined,
    }
  },
  mounted() {
    GetSequenceSmartSelector().then(response => {
      this.tabs = Object.keys(response.body)
      this.tabs.push('search')
      this.lists = response.body
    })
  }
}
</script>