<template>
  <th
    class="column-filter">
    <div class="flex-separate middle">
      <span v-help="`section.dwcTable.${title}`">{{ title }}</span>
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
      v-if="show && !disabled"
      class="panel content filter-container"
    >
      <div
        v-if="!value"
        class="horizontal-left-content"
      >
        <autocomplete
          :url="`/import_datasets/${importId}/dataset_records/autocomplete_data_fields.json`"
          :add-params="{
            field: field,
            per: per
          }"
          :send-label="value"
          :autofocus="true"
          param="value"
          @getItem="applyFilter"
          placeholder="Search"
          type="text"
        />
      </div>
      <div
        v-else
        class="flex-separate middle"
      >
        <input
          type="text"
          class="full_width"
          :value="value"
          disabled>
        <span
          @click="unselect"
          class="button circle-button btn-undo button-default"
        />
      </div>
      <div class="horizontal-left-content middle margin-small-top">
        <input
          v-model="replace"
          class="full_width margin-small-right"
          placeholder="Replace"
          type="text"
          :disabled="!value">
        <button
          type="button"
          class="button normal-input button-default"
          :disabled="!value || !replace.length"
          @click="replaceField">
          OK
        </button>
      </div>
    </div>
  </th>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetterNames } from '../store/getters/getters'
import { UpdateColumnField } from '../request/resources'
import ColumnMixin from './shared/columnMixin.js'

export default {
  mixins: [ColumnMixin],
  components: {
    Autocomplete
  },
  props: {
    columnIndex: {
      type: Number,
      required: true
    },
    field: {
      type: Number,
      required: true
    },
    value: {
      type: String,
      default: undefined
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
  methods: {
    applyFilter (value) {
      this.filter = value
      this.show = false
    },
    unselect () {
      this.filter = undefined
    },
    replaceField () {
      UpdateColumnField(this.importId, Object.assign({}, {
        field: this.columnIndex,
        value: this.replace
      }, this.paramsFilter)).then(() => {
        this.filter = this.replace
        this.replace = ''
      })
    }
  }
}
</script>
