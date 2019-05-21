<template>
  <div>
    <h2>Protocol</h2>
    <smart-selector
      v-model="view"
      :options="tabs"/>
    <ul
      class="no_bullets"
      v-if="optionList">
      <li
        v-for="item in list[view]"
        :key="item.id">
        <label>
          <label
            @click="addProtocol(item)">
            <input type="radio">
            <span v-html="item.object_tag"/>
          </label>
        </label>
      </li>
    </ul>
    <autocomplete
      url="/protocols/autocomplete"
      param="term"
      label="label_html"
    />
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import SmartSelector from 'components/switch'
import { GetProtocolSmartSelector } from '../request/resources'

export default {
  components: {
    Autocomplete,
    SmartSelector
  },
  computed: {
    optionList() {
      if (!this.view) return
      return Object.keys(this.list).includes(this.view)
    }
  },
  data () {
    return {
      lists: [],
      tabs: ['search'],
      view: undefined
    }
  },
  mounted() {
    GetProtocolSmartSelector().then(response => {
      this.lists = response.body
    })
  },
  methods: {
    addProtocol(protocol) {
      this.$emit('onAddProtocol', protocol)
    }
  }
}
</script>
