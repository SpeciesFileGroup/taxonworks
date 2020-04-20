<template>
  <div>
    <div class="separate-bottom horizontal-left-content">
      <switch-components
        class="full_width"
        v-model="view"
        :options="options"/>
      <default-pin
        v-if="pinSection"
        :section="pinSection"
        @getId="getObject"
        :type="pinType"/>
    </div>
    <template v-if="!addTabs.includes(view)">
      <ul
        v-if="view && view != 'search'"
        class="no_bullets">
        <li 
          v-for="item in lists[view]"
          :key="item.id">
          <label
            @click.prevent="sendObject(item)">
            <input type="radio">
            <span v-html="item[label]"/>
          </label>
        </li>
      </ul>
      <div v-else>
        <autocomplete
          v-if="autocomplete"
          :id="`smart-selector-${model}-autocomplete`"
          :input-id="inputId"
          class="separate-right"
          placeholder="Search..."
          :url="autocompleteUrl ? autocompleteUrl : `/${model}/autocomplete`"
          param="term"
          :add-params="autocompleteParams"
          label="label_html"
          :clear-after="clear"
          display="label"
          @getItem="getObject($event.id)"/>
      </div>
    </template>
    <slot :view="view">
    </slot>
  </div>
</template>

<script>

import SwitchComponents from 'components/switch'
import AjaxCall from 'helpers/ajaxCall'
import Autocomplete from 'components/autocomplete'
import OrderSmart from 'helpers/smartSelector/orderSmartSelector'
import SelectFirst from 'helpers/smartSelector/selectFirstSmartOption'
import DefaultPin from 'components/getDefaultPin'

export default {
  components: {
    SwitchComponents,
    Autocomplete,
    DefaultPin
  },
  props: {
    label: {
      type: String,
      default: 'object_tag'
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
    view(newVal) {
      this.$emit('onTabSelected', newVal)
    }
  },
  mounted () {
    AjaxCall('get', `/${this.model}/select_options`, { params: { klass: this.klass, target: this.target } }).then(response => {
      this.options = OrderSmart(Object.keys(response.body))
      this.lists = response.body
      this.view = SelectFirst(this.lists, this.options)
      if(this.search) {
        this.options.push('search')
        if(!this.view) {
          this.view = 'search'
        }
      }
      this.options = this.options.concat(this.addTabs)
    })
  },
  methods: {
    getObject(id) {
      AjaxCall('get', this.getUrl ? `${this.getUrl}${id}.json` : `/${this.model}/${id}.json`).then(response => {
        this.$emit('selected', response.body)
      })
    },
    sendObject(item) {
      this.$emit('selected', item)
    }
  }
}
</script>
