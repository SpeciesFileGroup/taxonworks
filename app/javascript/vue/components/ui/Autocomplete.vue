/* Parameters: mim: Minimum input length needed before make a search query time:
Minimum time needed after a key pressed to make a search query url: Ajax url
request placeholder: Input placeholder label: name of the propierty displayed on
the list, could be an array to reach the label autofocus: set autofocus display:
Sets the label of the item selected to be display on the input field getInput:
Get the input text clearAfter: Clear the input field after an item is selected
nested: Used to make a list of properties to reach the list headers: Set the
headers to be used in the call. Using it will override the common headers
:add-param: Send custom parameters Example:
<autocomplete url="/contents/filter.json" param="hours_ago">
    </autocomplete>
*/
<template>
  <div class="vue-autocomplete">
    <input
      type="text"
      ref="autofocus"
      :id="inputId"
      :style="inputStyle"
      :placeholder="placeholder"
      :autofocus="autofocus"
      :disabled="disabled"
      v-model="type"
      v-bind="inputAttributes"
      autocomplete="off"
      :class="[
        'vue-autocomplete-input normal-input',
        spinner && 'ui-autocomplete-loading',
        !spinner && 'vue-autocomplete-input-search',
        inputClass
      ]"
      @input="checkTime(), sendType()"
      @keydown.down="downKey"
      @keydown.up="upKey"
      @keydown.enter="enterKey"
      @keyup="sendKeyEvent"
    />
    <ul
      class="vue-autocomplete-list"
      v-show="showList"
      v-if="type && json.length"
    >
      <li
        v-for="(item, index) in limitList(json)"
        class="vue-autocomplete-item"
        :class="activeClass(index)"
        @mouseover="itemActive(index)"
        @click.prevent="itemClicked(index)"
      >
        <span
          v-if="typeof label !== 'function'"
          v-html="getNested(item, label)"
        />
        <span
          v-else
          v-html="label(item)"
        />
      </li>
      <li v-if="json.length == 20">Results may be truncated</li>
    </ul>
    <ul
      v-if="type && searchEnd && !json.length"
      class="vue-autocomplete-empty-list"
    >
      <li>--None--</li>
    </ul>
  </div>
</template>

<script>
import AjaxCall from '@/helpers/ajaxCall'
import Qs from 'qs'

export default {
  props: {
    modelValue: {
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
      default: undefined
    },

    nested: {
      type: [Array, String],
      default: () => []
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
      type: [String, Array, Function]
    },

    display: {
      type: String,
      default: ''
    },

    time: {
      type: [String, Number],
      default: 500
    },

    arrayList: {
      type: Array,
      default: undefined
    },

    excludedIds: {
      type: Array,
      default: undefined
    },

    min: {
      type: [String, Number],
      default: 1
    },

    addParams: {
      type: Object,
      default: () => ({})
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

    inputClass: {
      type: Array,
      default: () => []
    },

    inputStyle: {
      type: Object,
      default: () => ({})
    },

    inputAttributes: {
      type: Object,
      default: () => ({})
    }
  },

  emits: [
    'update:modelValue',
    'getInput',
    'getItem',
    'found',
    'keyEvent',
    'select'
  ],

  data() {
    return {
      spinner: false,
      showList: false,
      searchEnd: false,
      getRequest: 0,
      type: this.sendLabel,
      json: [],
      current: -1,
      controller: null
    }
  },

  mounted() {
    if (this.autofocus) {
      this.$nextTick(() => {
        this.$refs.autofocus.focus()
      })
    }
  },

  watch: {
    modelValue: {
      handler(newVal) {
        this.type = newVal || ''
      },
      immediate: true
    },
    type(newVal) {
      if (this.type?.length < Number(this.min)) {
        this.json = []
      }
      this.$emit('update:modelValue', newVal)
    },
    sendLabel(val) {
      this.type = val || ''
    }
  },

  methods: {
    downKey() {
      if (this.showList && this.current < this.json.length) this.current++
    },

    upKey() {
      if (this.showList && this.current > 0) this.current--
    },

    enterKey() {
      if (this.showList && this.current > -1 && this.current < this.json.length)
        this.itemClicked(this.current)
    },

    sendItem(item) {
      this.$emit('update:modelValue', item)
      this.$emit('getItem', item)
      this.$emit('select', item)
    },

    sendKeyEvent(e) {
      this.$emit('keyEvent', e)
    },

    cleanInput() {
      this.type = ''
    },

    setText(value) {
      this.type = value
    },

    limitList(list) {
      if (this.limit == 0) {
        return list
      }

      return list.slice(0, this.limit)
    },

    clearResults() {
      this.json = []
    },

    getNested(item, nested) {
      if (nested) {
        if (Array.isArray(nested)) {
          let tmp = item
          this.nested.forEach((itemLabel) => {
            tmp = tmp[itemLabel]
          })
          return tmp
        } else if (typeof nested === 'string') {
          return item[nested]
        } else {
          return item
        }
      } else {
        return item
      }
    },

    itemClicked(index) {
      if (this.display.length) {
        this.type = this.clearAfter ? '' : this.json[index][this.display]
      } else {
        this.type = this.clearAfter
          ? ''
          : this.getNested(this.json[index], this.label)
      }

      if (this.autofocus) {
        this.$refs.autofocus.focus()
      }
      this.sendItem(this.json[index])
      this.showList = false
    },

    itemActive(index) {
      this.current = index
    },

    ajaxUrl() {
      var tempUrl =
        this.url + '?' + this.param + '=' + encodeURIComponent(this.type)
      var params = ''
      if (Object.keys(this.addParams).length) {
        params = `&${Qs.stringify(this.addParams, { arrayFormat: 'brackets' })}`
      }
      return tempUrl + params
    },

    sendType() {
      this.$emit('getInput', this.type)
    },

    checkTime() {
      this.current = -1
      this.searchEnd = false
      if (this.getRequest) {
        clearTimeout(this.getRequest)
      }
      this.getRequest = setTimeout(() => {
        this.update()
      }, this.time)
    },

    update() {
      if (this.type.length < Number(this.min)) return

      this.clearResults()

      if (this.arrayList) {
        this.json = this.arrayList.filter((item) =>
          item[this.label].toLowerCase().includes(this.type.toLowerCase())
        )
        this.searchEnd = true
        this.showList = this.json.length > 0
      } else {
        this.spinner = true
        this.controller?.abort()
        this.controller = new AbortController()

        AjaxCall('get', this.ajaxUrl(), {
          headers: this.headers,
          signal: this.controller.signal
        })
          .then(({ body }) => {
            this.json = this.getNested(body, this.nested)
            if (this.excludedIds) {
              this.json = this.json.filter(
                (item) => !this.excludedIds.includes(item.id)
              )
            }
            this.showList = this.json.length > 0
            this.searchEnd = true
            this.$emit('found', this.showList)
          })
          .catch(() => {})
          .finally(() => {
            this.spinner = false
          })
      }
    },

    activeClass(index) {
      return {
        active: this.current === index
      }
    },

    setFocus() {
      this.$refs.autofocus.focus()
    }
  }
}
</script>
