<template>
  <modal-component
    :container-style="{ width: '500px' }"
    @close="$emit('close')">
    <template #header>
      <h3>Data links</h3>
    </template>
    <template #body>
      <ul class="no_bullets context-menu">
        <li
          v-for="button in links"
          :key="button.label">
          <button
            type="button"
            class="button normal-input button-default"
            @click="setSelected(button)">
            {{ button.label }}
          </button>
        </li>
      </ul>
      <div
        class="margin-medium-top">
        <smart-selector
          target="Otu"
          :model="selected.model"
          :label="selected.labelProperty"
          autofocus
          @selected="sendObject"
        />
      </div>
    </template>
  </modal-component>
</template>

<script>

import BUTTON_LINKS from './buttonLinks.js'
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
      links: BUTTON_LINKS,
      selected: BUTTON_LINKS[0]
    }
  },

  methods: {
    setSelected (item) {
      this.selected = item
    },

    sendObject (item) {
      const {
        labelFunction,
        labelProperty,
        model
      } = this.selected

      const label = labelFunction ? labelFunction(item) : item[labelProperty]

      const payload = {
        label,
        link: `/${model}/${item.id}`
      }

      this.$emit('selected', payload)
      this.$emit('close')
    }
  }
}
</script>
