<template>
  <div v-hotkey="shortcuts">
    <modal-component
      @close="showModal = false"
      v-if="showModal">
      <template #header>
        <h3>Pinboard navigator - Browse tasks</h3>
      </template>
      <template #body>
        <ul
          v-if="Object.keys(defaultItems).length"
          class="no_bullets">
          <template v-for="(item, key) in sections">
            <li
              class="margin-small-bottom"
              v-if="defaultItems[key]"
              :key="key">
              <transition
                v-if="selected && selected.klass == key"
                name="bounce"
                @after-enter="redirect"
                appear>
                <div class="horizontal-left-content cursor-pointer">
                  <div class="rounded-circle button-default horizontal-center-content circle-s middle margin-small-right">
                    <span class="capitalize"><b>{{ item.shortcut }}</b></span>
                  </div>
                  <span v-html="shorten(defaultItems[key].label, 38)"/>
                </div>
              </transition>
              <div
                v-else
                class="cursor-pointer dislay-inline-flex align-center"
                @click="selectItem(key, defaultItems[key])">
                <div
                  class="rounded-circle button-default horizontal-center-content circle-s middle margin-small-right">
                  <span class="capitalize"><b>{{ item.shortcut }}</b></span>
                </div>
                <span v-html="shorten(defaultItems[key].label, 38)"/>
              </div>
            </li>
          </template>
        </ul>
        <h4 v-else>Nothing is on your pinboard yet</h4>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import Shortcuts from './const/shortcuts.js'
import platformKey from 'helpers/getMacKey.js'
import { shorten } from 'helpers/strings.js'

export default {
  components: { ModalComponent },

  computed: {
    shortcuts () {
      const keys = {}

      for (const key in this.sections) {
        keys[this.sections[key].shortcut] = () => { this.selectItem(key, this.defaultItems[key]) }
      }

      keys[`${platformKey()}+g`] = this.openModal

      return keys
    }
  },

  data () {
    return {
      showModal: false,
      sections: this.orderShortcuts(Shortcuts),
      defaultItems: {},
      selected: undefined
    }
  },

  mounted () {
    TW.workbench.keyboard.createLegend(`${platformKey()}+g`, 'Open pinboard navigator', 'Pinboard')
  },

  methods: {
    redirect () {
      const klass = this.selected.klass

      window.open(`${this.sections[klass].path}?${this.sections[klass].param}=${this.selected.object.id}`, '_self')
    },

    selectItem (key, item) {
      this.selected = { klass: key, object: item }
    },

    openModal () {
      this.defaultItems = {}
      document.querySelectorAll('[data-pinboard-section]').forEach(node => {
        const element = node.querySelector('[data-insert="true"]')
        if (element) {
          this.defaultItems[node.getAttribute('data-pinboard-section')] = {
            id: element.getAttribute('data-pinboard-object-id'),
            label: element.querySelector('a').textContent
          }
        }
      })

      this.selected = undefined
      this.showModal = true
    },

    shorten: shorten,

    orderShortcuts (sections) {
      const ordered = {}
      Object.keys(sections).sort((a, b) => a.shortcut - b.shortcut).forEach(key => {
        ordered[key] = sections[key]
      })
      return ordered
    }
  }
}
</script>
<style scoped>
  .bounce-enter-active {
    animation: bounce-in 1s;
  }
  .bounce-leave-active {
    animation: bounce-in 1s reverse;
  }
  @keyframes bounce-in {
    0% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.5) translateX(25%);
    }
    100% {
      transform: scale(1);
    }
  }
</style>