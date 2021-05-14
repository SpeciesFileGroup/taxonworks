/*
Parameters:

          mim: Minimum input length needed before make a search query
         time: Minimum time needed after a key pressed to make a search query
          url: Ajax url request
  placeholder: Input placeholder
        label: name of the propierty displayed on the list, could be an array to reach the label
   event-send: event name used to pass item selected
    autofocus: set autofocus
      display: Sets the label of the item selected to be display on the input field
     getInput: Get the input text
   clearAfter: Clear the input field after an item is selected
       nested: Used to make a list of properties to reach the list
      headers: Set the headers to be used in the call. Using it will override the common headers


   :add-param: Send custom parameters

  Example:
    <autocomplete
      url="/contents/filter.json"
      param="hours_ago">
    </autocomplete>
*/
<template>
  <div class="vue-autocomplete">
    <input
      :id="inputId"
      ref="autofocus"
      :style="inputStyle"
      class="vue-autocomplete-input normal-input"
      type="text"
      :placeholder="placeholder"
      @input="checkTime(), sendType()"
      v-model="type"
      @keydown.down="downKey"
      @keydown.up="upKey"
      @keydown.enter="enterKey"
      autocomplete="off"
      :autofocus="autofocus"
      :disabled="disabled"
      :class="{'ui-autocomplete-loading' : spinner, 'vue-autocomplete-input-search' : !spinner }">
    <ul 
      class="vue-autocomplete-list"
      v-show="showList"
      v-if="type && json.length">
      <li
        v-for="(item, index) in limitList(json)"
        class="vue-autocomplete-item"
        :class="activeClass(index)"
        @mouseover="itemActive(index)"
        @click.prevent="itemClicked(index)">
        <span
          v-if="(typeof label !== 'function')"
          v-html="getNested(item, label)"/>
        <span
          v-else
          v-html="label(item)"/>
      </li>
      <li v-if="json.length == 20">Results may be truncated</li>
    </ul>
    <ul 
      v-if="type && searchEnd && !json.length"
      class="vue-autocomplete-empty-list">
      <li>--None--</li>
    </ul>
  </div>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import Qs from 'qs'

export default {
  data: function () {
    return {
      spinner: false,
      showList: false,
      searchEnd: false,
      getRequest: 0,
      type: this.sendLabel,
      json: [],
      current: -1,
      requestId: Math.random().toString(36).substr(2, 5)
    }
  },

  mounted: function () {
    if (this.autofocus) {
      this.$refs.autofocus.focus()
    }
  },

  watch: {
    value (newVal) {
      this.type = newVal
    },
    type (newVal) {
      if (this.type?.length < Number(this.min)) {
        this.json = []
      }
      this.$emit('input', newVal)
    },
    sendLabel (val) {
      this.type = val || ''
    }
  },

  props: {

    value: {
      type: [String, Number]
    },

    inputId: {
      type: String,
      default: undefined
    },

    autofocus: {
      type: Boolean,
      default: false
    },

    disabled: {
      type: Boolean,
      default: false
    },

    url: {
      type: String,
      default: undefined
    },

    headers: {
      required: false,
      type: Object,
      default: () => { return {}}
    },

    nested: {
      type: [Array, String],
      default: () => { return [] }
    },

    clearAfter: {
      type: Boolean,
      default: false
    },

    sendLabel: {
      type: String,
      default: ''
    },

    label: { 
      type: [String, Array, Function],
    },

    display: {
      type: String,
      default: ''
    },

    time: {
      type: String,
      default: '500'
    },

    arrayList: {
      type: Array,
      default: undefined
    },

    min: {
      type: [String, Number],
      default: 1
    },

    addParams: {
      type: Object,
      default: () => {
        return {}
      }
    },

    limit: {
      type: Number,
      default: 0
    },

    placeholder: {
      type: String,
      default: ''
    },

    param: {
      type: String,
      default: 'value'
    },

    eventSend: {
      type: String,
      default: 'itemSelect'
    },

    inputStyle: {
      type: Object,
      default: () => {}
    }
  },

  methods: {
    downKey() {
      if(this.showList && this.current < this.json.length)
        this.current++
    },

    upKey() {
      if(this.showList && this.current > 0)
        this.current--
    },

    enterKey() {
      if(this.showList && this.current > -1 && this.current < this.json.length)
        this.itemClicked(this.current)
    },

    sendItem: function (item) {
      this.$emit('input', item)
      this.$parent.$emit(this.eventSend, item)
      this.$emit('getItem', item)
    },

    cleanInput() {
      this.type = ''
    },

    setLabel(value) {
      this.type = value
    },

    limitList: function (list) {
      if (this.limit == 0) { return list }

      return list.slice(0, this.limit)
    },

    clearResults: function () {
      this.json = []
    },

    getNested(item, nested) {
      if(nested) {
        if(Array.isArray(nested)) {
          let tmp = item
          this.nested.forEach((itemLabel) => {
            tmp = tmp[itemLabel]
          })
          return tmp
        }
        else if(typeof nested === 'string') {
          return item[nested]
        }
        else {
          return item
        }
      }
      else {
        return item
      }
    },

    itemClicked: function (index) {
      if (this.display.length) { this.type = (this.clearAfter ? '' : this.json[index][this.display]) } else {
        this.type = (this.clearAfter ? '' : this.getNested(this.json[index], this.label))
      }

      if (this.autofocus) {
        this.$refs.autofocus.focus()
      }
      this.sendItem(this.json[index])
      this.showList = false
    },

    itemActive: function (index) {
      this.current = index
    },

    ajaxUrl: function () {
      var tempUrl = this.url + '?' + this.param + '=' + encodeURIComponent(this.type)
      var params = ''
      if (Object.keys(this.addParams).length) {
        params = `&${Qs.stringify(this.addParams, { arrayFormat: 'brackets' })}`
      }
      return tempUrl + params
    },

    sendType: function () {
      this.$emit('getInput', this.type)
    },

    checkTime: function () {
      var that = this
      this.current = -1
      this.searchEnd = false
      if (this.getRequest) {
        clearTimeout(this.getRequest)
      }
      this.getRequest = setTimeout(function () {
        that.update()
      }, that.time)
    },

    update: function () {
      if (this.type.length < Number(this.min)) return
      this.spinner = true
      this.clearResults()
      if (this.arrayList) {
        var finded = []
        var that = this

        this.arrayList.forEach(function (item) {
          if (item[that.label].toLowerCase().includes(that.type.toLowerCase())) {
            finded.push(item)
          }
        })

        this.spinner = false
        this.json = finded
        this.searchEnd = true
        this.showList = (this.json.length > 0)
      } else {
        AjaxCall('get', this.ajaxUrl(), {
          requestId: this.requestId
        }).then(response => {
          this.json = this.getNested(response.body, this.nested)
          this.showList = (this.json.length > 0)
          this.spinner = false
          this.searchEnd = true
          this.$emit('found', this.showList)
        }, response => {
          // error callback
          this.spinner = false
        })
      }
    },
    activeClass: function activeClass (index) {
      return {
        active: this.current === index
      }
    },
    activeSpinner: function () {
      return 'ui-autocomplete-loading'
    },
    setFocus () {
      this.$refs.autofocus.focus()
    }
  }
}
</script>
