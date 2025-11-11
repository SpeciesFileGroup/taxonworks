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
        !spinner && 'vue-autocomplete-input-search',
        inputClass
      ]"
      @input="checkTime(), sendType()"
      @keydown.down="downKey"
      @keydown.up="upKey"
      @keydown.enter="enterKey"
      @keyup="sendKeyEvent"
      @focus="() => (showList = true)"
      @blur="onBlur"
    />
    <AutocompleteSpinner v-if="spinner" />
    <teleport to="body">
      <ul
        v-if="type && searchEnd"
        class="vue-autocomplete-list"
        v-show="showList"
        ref="dropdown"
        :style="dropdownStyle"
        @mousedown="onDropdownMousedown"
      >
        <template v-if="json.length">
          <li
            v-for="(item, index) in limitList(json)"
            class="vue-autocomplete-item"
            :class="activeClass(index)"
            ref="items"
            :title="escapeHtml(getNested(item, label))"
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
        </template>
        <li
          v-else
          class="vue-autocomplete-empty-list"
        >
          --None--
        </li>
      </ul>
    </teleport>
  </div>
</template>

<script>
import { escapeHtml } from '@/helpers'
import AjaxCall from '@/helpers/ajaxCall'
import AutocompleteSpinner from './Autocomplete/AutocompleteSpinner.vue'
import Qs from 'qs'

export default {
  components: {
    AutocompleteSpinner
  },

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
      controller: null,
      dropdownStyle: {},
      isFocus: false,
      items: []
    }
  },

  mounted() {
    if (this.autofocus) {
      this.$nextTick(() => {
        this.$refs.autofocus.focus()
      })
    }

    window.addEventListener('resize', this.updateDropdownPosition)
  },

  beforeUnmount() {
    window.removeEventListener('resize', this.updateDropdownPosition)
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
    escapeHtml,

    downKey() {
      if (this.showList && this.current < this.json.length) {
        this.current++
      }

      this.scrollToActiveItem()
    },

    upKey() {
      if (this.showList && this.current > 0) {
        this.current--
      }

      this.scrollToActiveItem()
    },

    enterKey() {
      if (this.showList && this.current > -1 && this.current < this.json.length)
        this.itemClicked(this.current)
    },

    scrollToActiveItem() {
      this.$nextTick(() => {
        const dropdown = this.$refs.dropdown
        const items = this.$refs.items
        const activeEl = items?.[this.current]
        if (dropdown && activeEl) {
          const dropdownRect = dropdown.getBoundingClientRect()
          const itemRect = activeEl.getBoundingClientRect()

          if (itemRect.bottom > dropdownRect.bottom) {
            dropdown.scrollTop += itemRect.bottom - dropdownRect.bottom
          } else if (itemRect.top < dropdownRect.top) {
            dropdown.scrollTop -= dropdownRect.top - itemRect.top
          }
        }
      })
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

    onBlur() {
      if (this.preventBlur) {
        this.preventBlur = false
        return
      }
      this.showList = false
      this.current = -1
    },

    onDropdownMousedown() {
      this.preventBlur = true
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

      this.$nextTick(() => {
        if (this.autofocus) this.$refs.autofocus.focus()
      })
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
        this.showList = true
        this.$nextTick(this.updateDropdownPosition)
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
            this.showList = true
            this.searchEnd = true
            this.$emit('found', this.showList)
            this.$nextTick(this.updateDropdownPosition)
          })
          .catch(() => {})
          .finally(() => {
            this.spinner = false
          })
      }
    },

    updateDropdownPosition() {
      this.$nextTick(() => {
        const input = this.$refs.autofocus
        const dropdown = this.$refs.dropdown
        const items = this.$refs.items

        if (!input || !dropdown) return

        const rect = input.getBoundingClientRect()
        const viewportHeight = window.innerHeight
        const viewportWidth = window.innerWidth

        const spaceBelow = viewportHeight - rect.bottom
        const spaceAbove = rect.top

        const showAbove = spaceBelow < 150 && spaceAbove > spaceBelow
        const maxWidth = viewportWidth - rect.left - 32
        const maxHeight = Math.min(
          showAbove ? spaceAbove - 12 : spaceBelow - 12,
          500
        )

        dropdown.style.removeProperty('width')
        dropdown.style.maxHeight = maxHeight + 'px'
        dropdown.style.minWidth = rect.width + 'px'
        dropdown.style.maxWidth = maxWidth + 'px'

        const contentWidth = items
          ? items.reduce((acc, li) => Math.max(acc, li.scrollWidth), 0)
          : 0
        const finalWidth = Math.min(contentWidth, maxWidth)
        const dropdownHeight = dropdown.offsetHeight || maxHeight

        const top = showAbove
          ? rect.top + window.scrollY - dropdownHeight - 6
          : rect.bottom + window.scrollY + 2

        const left = rect.left + window.scrollX

        this.dropdownStyle = {
          top: `${Math.max(top, 0)}px`,
          left: `${Math.max(left, 0)}px`,
          width: finalWidth + 'px',
          minWidth: rect.width + 'px',
          maxWidth: maxWidth + 'px'
        }
      })
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

<style>
.vue-autocomplete-input {
  z-index: 2000;
  font-size: 12px;
  padding: 0px;
  position: static;
  padding-left: 0.9em;
  border-radius: 2px;
  border: 1px solid var(--border-color);
  min-height: 28px;
  background-color: var(--input-bg-color);
  box-sizing: border-box;
  padding-right: 24px;
  background-size: 18px;
  background-position: right 4px center;
  background-repeat: no-repeat;
  width: 100%;
}

.vue-autocomplete {
  position: relative;
}

.vue-autocomplete-list {
  display: block;
  max-height: 500px;
  overflow-y: auto;
  overflow-x: hidden;
  z-index: 999998;
  background-color: var(--panel-bg-color);
  margin: 0;
  padding: 0;
  list-style: none;
  border: 1px solid var(--border-color);
  border-top: none;
  border-bottom: 4px solid var(--border-color);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  box-sizing: border-box;
  position: absolute;

  width: auto;
  min-width: 100%;
  max-width: calc(100vw - 32px);
  overflow-x: hidden;
  white-space: nowrap;

  li {
    cursor: pointer;
    padding: calc(var(--standard-padding, 8px) * 0.5);
    border-top: 1px solid var(--border-color);
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
    padding: 6px 12px;
  }

  .active {
    background-color: var(--border-color);
  }
}
</style>
