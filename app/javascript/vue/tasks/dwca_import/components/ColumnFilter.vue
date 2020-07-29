<template>
  <th class="column-filter">
    <div class="flex-separate middle">
      <span>{{ title }}</span>
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
      @mouseleave="show = false"
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
          placeholder="Type to search..."
          type="text"
        />
      </div>
      <div
        v-else
        class="flex-separate middle"
      >
        <span>{{ value }}</span>
        <span
          @click="unselect"
          class="button circle-button btn-delete button-default"
        />
      </div>
    </div>
  </th>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetterNames } from '../store/getters/getters'

export default {
  components: {
    Autocomplete
  },
  props: {
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
    filter: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    applied () {
      return this.value
    },
    importId () {
      return this.$store.getters[GetterNames.GetDataset].id
    }
  },
  data () {
    return {
      per: 25,
      show: false
    }
  },
  methods: {
    applyFilter (value) {
      this.filter = value
      this.show = false
    },
    unselect () {
      this.filter = undefined
    }
  }
}
</script>
