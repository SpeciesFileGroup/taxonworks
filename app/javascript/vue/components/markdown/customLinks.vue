<template>
  <modal-component @close="$emit('close')">
    <template #header>
      <h3>Data links</h3>
    </template>
    <template #body>
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
    </template>
  </modal-component>
</template>

<script>

import buttonLinks from './buttonLinks.js'
import ModalComponent from 'components/ui/Modal'
import SmartSelector from 'components/ui/SmartSelector'

export default {
  components: {
    ModalComponent,
    SmartSelector
  },

  emits: [
    'selected',
    'close'
  ],

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
        link: `${window.location.origin}${this.selected.link}?${this.selected.param}=${item.id}`
      }

      this.$emit('selected', data)
      this.$emit('close')
    }
  }
}
</script>
