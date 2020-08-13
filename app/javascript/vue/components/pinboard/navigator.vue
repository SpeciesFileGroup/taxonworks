<template>
  <div
    v-shortkey="['ctrl', 'p']"
    @shortkey="openModal">
    <modal-component
      @close="showModal = false"
      v-if="showModal">
      <h3 slot="header">Pinboard navigator - Browse tasks</h3>
      <div slot="body">
        <ul class="no_bullets">
          <template v-for="(item, key) in defaultItems">
            <li
              class="margin-small-bottom"
              v-if="sections[key]"
              :key="key"
              v-shortkey="[sections[key].shortcut]"
              @shortkey="selectItem(key, item)">
              <transition
                v-if="selected && selected.klass == key"
                name="bounce"
                @after-enter="test"
                appear>
                <div class="horizontal-left-content cursor-pointer">
                  <div class="rounded-circle button-default horizontal-center-content circle-s middle margin-small-right">
                    <span class="capitalize"><b>{{ sections[key].shortcut }}</b></span>
                  </div>
                  <span v-html="shorten(item.label, 38)"/>
                </div>
              </transition>
              <div
                v-else
                class="horizontal-left-content cursor-pointer">
                <div class="rounded-circle button-default horizontal-center-content circle-s middle margin-small-right">
                  <span class="capitalize"><b>{{ sections[key].shortcut }}</b></span>
                </div>
                <span v-html="shorten(item.label, 38)"/>
              </div>
            </li>
          </template>
        </ul>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import Shortcuts from './const/shortcuts.js'
import { shorten } from 'helpers/strings.js'

export default {
  components: {
    ModalComponent
  },
  data () {
    return {
      showModal: false,
      sections: Shortcuts,
      defaultItems: {},
      selected: undefined
    }
  },
  methods: {
    test () {
      const klass = this.selected.klass
      window.open(`${this.sections[klass].path}?${this.sections[klass].param}=${this.selected.object.id}`, '_self')
    },
    selectItem (key, item) {
      this.selected = { klass: key, object: item }
    },
    openModal () {
      this.defaultItems = {}
      document.querySelectorAll('[data-pinboard-section]').forEach(node => {
        this.defaultItems[node.getAttribute('data-pinboard-section')] = {
          id: node.querySelector('[data-insert="true"]').getAttribute('data-pinboard-object-id'),
          label: node.querySelector('[data-insert="true"] a').textContent
        }
      })

      this.selected = undefined
      this.showModal = true
    },
    shorten: shorten
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