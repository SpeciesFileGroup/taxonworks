<template>
  <div>
    <div class="separate-bottom horizontal-left-content">
      <switch-components
        class="full_width capitalize"
        v-model="view"
        :options="options"/>
      <default-pin
        v-if="pinSection"
        :section="pinSection"
        @getId="getObject"
        :type="pinType"/>
    </div>
    <slot name="header"/>
    <template v-if="!addTabs.includes(view)">
      <div
        class="margin-medium-bottom">
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
          @getItem="getObject($event.id)"/>
        <otu-picker
          v-if="otuPicker"
          :input-id="inputId"
          :clear-after="true"
          @getItem="getObject($event.id)"/>
      </div>
      <slot name="body"/>
      <ul
        v-if="view && view != 'search'"
        class="no_bullets"
        :class="{ 'flex-wrap-row': inline }">
        <template v-for="item in lists[view]">
          <li
            v-if="filterItem(item)"
            :key="item.id">
            <template
              v-if="buttons">
              <button
                type="button"
                class="button normal-input tag_button"
                :class="buttonClass"
                v-html="item[label]"
                @click.prevent="sendObject(item)"/>
            </template>
            <template
              v-else>
              <label class="cursor-pointer">
                <input
                  :name="name"
                  @click="sendObject(item)"
                  :value="item"
                  :checked="selectedItem && item.id == selectedItem.id"
                  type="radio">
                <span v-html="item[label]"/>
              </label>
            </template>
          </li>
        </template>
      </ul>
    </template>
    <slot :name="view" />
    <slot />
    <slot name="footer"/>
  </div>
</template>

<script>

import SwitchComponents from 'components/switch'
import AjaxCall from 'helpers/ajaxCall'
import Autocomplete from 'components/autocomplete'
import OrderSmart from 'helpers/smartSelector/orderSmartSelector'
import SelectFirst from 'helpers/smartSelector/selectFirstSmartOption'
import DefaultPin from 'components/getDefaultPin'
import OtuPicker from 'components/otu/otu_picker/otu_picker'
import { getUnique } from 'helpers/arrays.js'

export default {
  components: {
    SwitchComponents,
    Autocomplete,
    DefaultPin,
    OtuPicker
  },
  props: {
    value: {
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
    search: {
      type: Boolean,
      default: true
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
    addTabs: {
      type: Array,
      default: () => { return [] }
    },
    params: {
      type: Object,
      default: () => { return {} }
    },
    customList: {
      type: Object,
      default: () => { return {} }
    },
    name: {
      type: String,
      required: false,
      default: () => { return Math.random().toString(36).substr(2, 5) }
    },
    filterIds: {
      type: [Number, Array],
      default: () => []
    }
  },
  computed: {
    selectedItem: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      lists: {},
      view: undefined,
      options: [],
      firstTime: true
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
  mounted () {
    this.refresh()
  },
  methods: {
    getObject (id) {
      AjaxCall('get', this.getUrl ? `${this.getUrl}${id}.json` : `/${this.model}/${id}.json`).then(response => {
        this.sendObject(response.body)
      })
    },
    sendObject (item) {
      this.lastSelected = item
      this.selectedItem = item
      this.$emit('selected', item)
    },
    filterItem (item) {
      return Array.isArray(this.filterIds) ? !this.filterIds.includes(item.id) : this.filterIds !== item.id
    },
    refresh (forceUpdate = false) {
      if (this.alreadyOnLists() && !forceUpdate) return
      AjaxCall('get', `/${this.model}/select_options`, { params: Object.assign({}, { klass: this.klass, target: this.target }, this.params) }).then(response => {
        this.lists = response.body
        this.addCustomElements()
        this.options = Object.keys(this.lists)

        if (this.firstTime) {
          this.view = SelectFirst(this.lists, this.options)
          this.firstTime = false
        }

        if (this.search) {
          this.options.push('search')
          if (!this.view) {
            this.view = 'search'
          }
        }
        this.options = this.options.concat(this.addTabs)
        this.options = OrderSmart(this.options)
      })
    },
    addCustomElements () {
      const keys = Object.keys(this.customList)
      if (keys.length) {
        keys.forEach(key => {
          if (this.lists[key]) {
            this.$set(this.lists, key, getUnique(this.lists[key].concat(this.customList[key]), 'id'))
          } else {
            this.$set(this.lists, key, this.customList[key])
            this.options.push(key)
            this.options = OrderSmart(this.options)
          }
        })
      }
      this.view = SelectFirst(this.lists, this.options)
    },
    alreadyOnLists () {
      return this.lastSelected ? [].concat(...Object.values(this.lists)).find(item => item.id === this.lastSelected.id) : false
    },
    setFocus () {
      this.$refs.autocomplete.setFocus()
    }
  }
}
</script>
