<template>
  <modal-component @close="$emit('close')">
    <h3 slot="header">Data links</h3>
    <div slot="body">
      <ul class="no_bullets context-menu">
        <li v-for="button in links">
          <button
            type="button"
            class="button normal-input button-default"
            @click="setSelected(button)">
            {{ button.label }}
          </button>
        </li>
      </ul>
      <div v-if="selected">
        <smart-selector
          target="Otu"
          :model="selected.model"
          @selected="sendObject"/>
      </div>
    </div>
  </modal-component>
</template>

<script>

import buttonLinks from './buttonLinks.js'
import ModalComponent from 'components/modal'
import SmartSelector from 'components/smartSelector'

export default {
  components: {
    ModalComponent,
    SmartSelector
  },
  data () {
    return {
      links: buttonLinks(),
      selected: undefined
    }
  },
  methods: {
    setSelected (item) {
      this.selected = item
    },
    sendObject (item) {
      const data = {
        label: item[this.selected.propertyLabel],
        link: `${window.location.href.split('/').slice(0, 3).join('/')}${this.selected.link}?${this.selected.param}=${item.id}`
      }
      this.$emit('selected', data)
      this.$emit('close')
    }
  }
}
</script>
