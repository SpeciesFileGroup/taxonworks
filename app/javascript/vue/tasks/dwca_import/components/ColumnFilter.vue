<template>
  <th
    class="column-filter">
    <div class="flex-separate middle">
      <span v-help="`section|dwcTable|${title}`">{{ title }}</span>
      <div
        class="margin-small-left"
        @keyup.esc="show = false"
      >
        <button
          class="button"
          :disabled="disabled"
          :class="{
            'button-data': applied,
            'button-default': !applied
          }"
          @click="show = !show"
        >
          ▼
        </button>
      </div>
    </div>
    <div
      v-show="show && !disabled"
      class="panel content filter-container"
    >
      <div class="horizontal-left-content" >
        <autocomplete
          ref="autocomplete"
          :url="`/import_datasets/${importId}/dataset_records/autocomplete_data_fields.json`"
          :add-params="{
            field: field,
            per: per,
            ...paramsFilter
          }"
          autofocus
          param="value"
          @getItem="applyFilter"
          :disabled="!!modelValue"
          placeholder="Search"
          type="text"
        />
        <span
          v-if="modelValue"
          @click="unselect"
          class="button circle-button btn-undo button-default"
        />
      </div>
      <div class="horizontal-left-content middle margin-small-top flexbox">
        <input
          v-model="replace"
          class="margin-small-right item"
          placeholder="Replace"
          type="text"
          :disabled="!modelValue">
        <button
          type="button"
          class="button normal-input button-default"
          :disabled="!modelValue || !replace.length"
          @click="emitReplace">
          OK
        </button>
      </div>
    </div>
  </th>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { GetterNames } from '../store/getters/getters'
import ColumnMixin from './shared/columnMixin.js'

export default {
  mixins: [ColumnMixin],

  components: { Autocomplete },

  props: {
    columnIndex: {
      type: Number,
      required: true
    },
    field: {
      type: Number,
      required: true
    },
    disabled: {
      type: Boolean,
      default: false
    },
    title: {
      type: String,
      required: true
    }
  },

  emits: ['replace'],

  computed: {
    importId () {
      return this.$store.getters[GetterNames.GetDataset].id
    },
    paramsFilter () {
      return this.$store.getters[GetterNames.GetParamsFilter]
    }
  },

  data () {
    return {
      per: 25,
      show: false,
      replace: ''
    }
  },

  watch: {
    filter (newVal) {
      if (!newVal) {
        this.$refs.autocomplete.setText('')
      }
    }
  },

  methods: {
    applyFilter (value) {
      this.filter = value
    },
    unselect () {
      this.filter = undefined
    },
    emitReplace () {
      this.$emit('replace', {
        columnIndex: this.columnIndex,
        replaceValue: this.replace,
        currentValue: this.value
      })
    }
  }
}
</script>
