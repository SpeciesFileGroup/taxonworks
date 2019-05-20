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
  </div>
</template>

<script>

import SmartSelector from 'components/switch'

export default {
  components: {
    SmartSelector
  },
  computed: {
    optionList() {
      return Object.keys(this.list).includes(this.view)
    }
  },
  data () {
    return {
      lists: [],
      tabs: [],
      view: undefined
    }
  },
  methods: {
    addProtocol(protocol) {
      this.$emit('onAddProtocol', protocol)
    }
  }
}
</script>
