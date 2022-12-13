<template>
  <div>
    <div class="separate-bottom horizontal-left-content">
      <switch-components
        class="full_width capitalize"
        v-model="view"
        ref="tabselector"
        :options="options"
      />
      <default-pin
        v-if="pinSection"
        class="margin-small-left"
        :section="pinSection"
        :type="pinType"
        @get-id="getObject"
      />
      <slot name="tabs-right" />
    </div>
    <slot name="header" />
    <template v-if="!addTabs.includes(view)">
      <div class="margin-medium-bottom">
        <autocomplete
          ref="autocomplete"
          v-if="autocomplete"
          :id="`smart-selector-${model}-autocomplete`"
          :input-id="inputId"
          placeholder="Search..."
          :url="autocompleteUrl ? autocompleteUrl : `/${model}/autocomplete`"
          param="term"
          :add-params="autocompleteParams"
          label="label_html"
          :clear-after="clear"
          display="label"
          :autofocus="autofocus"
          @key-event="changeTab"
          @get-item="getObject($event.id)"
        />
        <otu-picker
          v-if="otuPicker"
          :input-id="inputId"
          :clear-after="true"
          @get-item="getObject($event.id)"
        />
      </div>
      <slot name="body" />
      <template v-if="isImageModel">
        <div class="flex-wrap-row">
          <div
            v-for="image in lists[view]"
            :key="image.id"
            class="thumbnail-container margin-small cursor-pointer"
            @click="sendObject(image)"
          >
            <img
              :width="image.alternatives.thumb.width"
              :height="image.alternatives.thumb.height"
              :src="image.alternatives.thumb.image_file_url"
            >
          </div>
        </div>
      </template>
      <template v-else>
        <ul
          v-if="view"
          class="no_bullets"
          :class="{ 'flex-wrap-row': inline }"
        >
          <template
            v-for="item in lists[view]"
            :key="item.id"
          >
            <li
              v-if="filterItem(item)"
              class="list__item"
            >
              <template v-if="buttons">
                <button
                  type="button"
                  class="button normal-input tag_button"
                  :class="buttonClass"
                  v-html="item[label]"
                  @click.prevent="sendObject(item)"
                />
              </template>
              <template v-else>
                <label
                  class="cursor-pointer"
                  @mousedown="sendObject(item)"
                >
                  <input
                    :name="name"
                    @keyup="changeTab"
                    @keyup.enter="sendObject(item)"
                    @keyup.space="sendObject(item)"
                    :value="item.id"
                    :checked="selectedItem && item.id === selectedItem.id"
                    type="radio"
                  >
                  <span
                    :title="item[label]"
                    v-html="showLabel(item[label])"
                  />
                </label>
              </template>
            </li>
          </template>
        </ul>
      </template>
    </template>
    <slot :name="view" />
    <slot />
    <slot name="footer" />
  </div>
</template>

<script>

import SwitchComponents from 'components/switch'
import AjaxCall from 'helpers/ajaxCall'
import Autocomplete from 'components/ui/Autocomplete'
import OrderSmart from 'helpers/smartSelector/orderSmartSelector'
import SelectFirst from 'helpers/smartSelector/selectFirstSmartOption'
import DefaultPin from 'components/getDefaultPin'
import OtuPicker from 'components/otu/otu_picker/otu_picker'
import { shorten } from 'helpers/strings'

export default {
  components: {
    SwitchComponents,
    Autocomplete,
    DefaultPin,
    OtuPicker
  },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    },

    label: {
      type: String,
      default: 'object_tag'
    },

    inline: {
      type: Boolean,
      default: false
    },

    buttons: {
      type: Boolean,
      default: false
    },

    buttonClass: {
      type: String,
      default: 'button-data'
    },

    otuPicker: {
      type: Boolean,
      default: false
    },

    autocompleteParams: {
      type: Object,
      default: undefined
    },

    autocomplete: {
      type: Boolean,
      default: true
    },

    autocompleteUrl: {
      type: String,
      default: undefined
    },

    inputId: {
      type: String,
      default: undefined
    },

    getUrl: {
      type: String,
      default: undefined
    },

    model: {
      type: String,
      default: undefined
    },

    klass: {
      type: String,
      default: undefined
    },

    target: {
      type: String,
      default: undefined
    },

    selected: {
      type: [Array, String],
      default: undefined
    },

    clear: {
      type: Boolean,
      default: true
    },

    pinSection: {
      type: String,
      default: undefined
    },

    pinType: {
      type: String,
      default: undefined
    },

    shorten: {
      type: [Number, String],
      default: undefined
    },

    addTabs: {
      type: Array,
      default: () => []
    },

    params: {
      type: Object,
      default: () => ({})
    },

    customList: {
      type: Object,
      default: () => ({})
    },

    name: {
      type: String,
      required: false,
      default: () => (Math.random().toString(36).substr(2, 5))
    },

    filterIds: {
      type: [Number, Array],
      default: () => []
    },

    filterBy: {
      type: String,
      default: 'id'
    },

    filter: {
      type: Function,
      default: undefined
    },

    lockView: {
      type: Boolean,
      default: true
    },

    autofocus: {
      type: Boolean,
      default: false
    },

    extend: {
      type: Array,
      default: () => []
    }
  },

  emits: [
    'update:modelValue',
    'onTabSelected',
    'selected'
  ],

  computed: {
    selectedItem: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    isImageModel () {
      return this.model === 'images'
    },

    actionKey () {
      return navigator.platform.indexOf('Mac') > -1
        ? 'Control'
        : 'Alt'
    }
  },

  data () {
    return {
      lists: {},
      view: undefined,
      options: []
    }
  },

  watch: {
    view (newVal) {
      this.$emit('onTabSelected', newVal)
    },
    customList: {
      handler () {
        this.addCustomElements()
      },
      deep: true
    },
    model (newVal) {
      this.refresh()
    }
  },

  created () {
    this.refresh()
    document.addEventListener('smartselector:update', this.refresh)
  },

  unmounted () {
    document.removeEventListener('smartselector:update', this.refresh)
  },

  methods: {
    getObject (id) {
      AjaxCall('get', this.getUrl ? `${this.getUrl}${id}.json` : `/${this.model}/${id}.json`, { params: { extend: this.extend } }).then(response => {
        this.sendObject(response.body)
      })
    },

    sendObject (item) {
      this.lastSelected = item
      this.selectedItem = item
      this.$emit('selected', item)
    },

    filterItem (item) {
      if (this.filter) {
        return this.filter(item)
      }

      return Array.isArray(this.filterIds)
        ? !this.filterIds.includes(item[this.filterBy])
        : this.filterIds !== item[this.filterBy]
    },

    showLabel (label) {
      return this.shorten
        ? shorten(label, Number(this.shorten))
        : label
    },

    refresh (forceUpdate = false) {
      if (this.alreadyOnLists() && !forceUpdate) return
      AjaxCall('get', `/${this.model}/select_options`, { params: Object.assign({}, { klass: this.klass, target: this.target }, { extend: this.extend }, this.params) }).then(response => {
        this.lists = response.body
        this.addCustomElements()
        this.options = Object.keys(this.lists).concat(this.addTabs)
        this.options = OrderSmart(this.options)

        this.view = SelectFirst(this.lists, this.options)

      }).catch(() => {
        this.options = []
        this.lists = []
        this.view = undefined
      })
    },
    addToList (listName, item) {
      const index = this.lists[listName].findIndex(({ id }) => id === item.id)

      if (index > -1) {
        this.lists[listName][index] = item
      } else {
        this.lists[listName].push(item)
      }
    },
    addCustomElements () {
      const keys = Object.keys(this.customList)
      if (keys.length) {
        keys.forEach(key => {
          this.lists[key] = this.customList[key]
          if (!this.lists[key]) {
            this.options.push(key)
            this.options = OrderSmart(this.options)
          }
        })
      }
      if (!this.lockView) {
        this.view = SelectFirst(this.lists, this.options)
      }
    },
    alreadyOnLists () {
      return this.lastSelected ? [].concat(...Object.values(this.lists)).find(item => item.id === this.lastSelected.id) : false
    },
    setFocus () {
      this.$refs.autocomplete.setFocus()
    },

    changeTab (e) {
      if (e.key !== this.actionKey) return
      const element = this.$refs.tabselector.$el

      element.querySelector('input:checked').focus()
    }
  }
}
</script>
<style scoped>
  input:focus + span {
    font-weight: bold;
  }

  .list__item {
    padding:2px 0;
  }
</style>
