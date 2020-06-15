<template>
  <div
    @keyup.esc="show = false"
    class="column-filter">
    <button
      class="button"
      :disabled="disabled"
      :class="{
        'button-data': applied,
        'button-default': !applied
      }"
      @click="show = !show">▼
    </button>
    <div
      v-if="show && !disabled"
      class="panel content filter-container margin-medium-top">
      <div
        v-if="!value"
        class="horizontal-left-content">
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
          type="text"/>
      </div>
      <div
        v-else
        class="flex-separate middle">
        <span>{{ value }}</span>
        <span
          @click="unselect"
          class="button circle-button btn-delete button-default"/>
      </div>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

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
    importId: {
      type: [String, Number],
      require: true
    },
    disabled: {
      type: Boolean,
      default: false
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

<style lang="scss" scoped>
  .column-filter {
    position: relative;

    .filter-container {
      transform: translateX(-50%);
      left:50%;
      position: absolute;
    }
  }
</style>
