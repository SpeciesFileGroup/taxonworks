<template>
  <div>
    <switch-components
      class="separate-bottom"
      v-model="view"
      :options="options"/>
    <template>
      <ul
        v-if="view && view != 'search'"
        class="no_bullets">
        <li 
          v-for="item in lists[view]"
          :key="item.id">
          <label
            @click="$emit('selected', item)">
            <input type="radio">
            <span v-html="item[label]"/>
          </label>
        </li>
      </ul>
      <div v-else>
        <autocomplete
          :id="`smart-selector-${model}-autocomplete`"
          class="separate-right"
          placeholder="Search..."
          :url="`/${model}/autocomplete`"
          param="term"
          label="label_html"
          :clear-after="clear"
          display="label"
          @getItem="getObject($event.id)"/>
      </div>
    </template>
  </div>
</template>

<script>

import SwitchComponents from 'components/switch'
import AjaxCall from 'helpers/ajaxCall'
import Autocomplete from 'components/autocomplete'
import OrderSmart from 'helpers/smartSelector/orderSmartSelector'
import SelectFirst from 'helpers/smartSelector/selectFirstSmartOption'

export default {
  components: {
    SwitchComponents,
    Autocomplete
  },
  props: {
    label: {
      type: String,
      default: 'object_tag'
    },
    model: {
      type: String,
      default: undefined
    },
    klass: {
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
    }
  },
  data () {
    return {
      lists: {},
      view: undefined,
      options: []
    }
  },
  mounted () {
    AjaxCall('get', `/${this.model}/select_options`, { params: { klass: this.klass } }).then(response => {
      this.options = OrderSmart(Object.keys(response.body))
      this.lists = response.body
      this.view = SelectFirst(this.lists, this.options)
      if(this.search) {
        this.options.push('search')
        if(!this.view) {
          this.view = 'search'
        }
      }
    })
  },
  methods: {
    getObject(id) {
      AjaxCall('get', `/${this.model}/${id}.json`).then(response => {
        this.$emit('selected', response.body)
      })
    }
  }
}
</script>
