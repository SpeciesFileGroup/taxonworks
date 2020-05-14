<template>
  <div
    @keyup.esc="show = false"
    class="column-filter">
    <span
      class="button"
      :class="{
        'button-data': value.length,
        'button-default': !value.length
      }"
      @click="show = !show">▼</span>
    <div
      v-if="show"
      class="panel content filter-container margin-medium-top">
      <div class="horizontal-left-content">
        <autocomplete
          url="not-defined-yet"
          @getInput="filter = $event"
          placeholder="Type to search..."
          type="text"/>
        <button
          type="button"
          class="button normal-input button-default margin-small-left"
          @click="applyFilter">
          Apply
        </button>
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
      type: String,
      required: true
    },
    value: {
      type: String,
      default: ''
    }
  },
  data () {
    return {
      filter: '',
      show: false
    }
  },
  methods: {
    applyFilter () {
      this.$emit('applied', this.filter)
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
