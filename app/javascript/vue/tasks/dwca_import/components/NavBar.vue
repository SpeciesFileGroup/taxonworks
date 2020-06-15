<template>
  <navbar-component
    :component-style="{
      position: 'fixed',
      bottom: '0px',
      zIndex: 200,
      margin: '0px'
    }">
    <div class="flex-separate middle">
      <div>
        <span>{{ rowsCount }} of {{ pagination.total }} records.</span>
      </div>
      <div>
        <button
          class="button normal-input button-default margin-small-right"
          :disabled="disabled"
          @click="$emit('select')">
          Select all
        </button>
        <button
          :disabled="disabled"
          class="button normal-input button-default margin-small-right"
          @click="$emit('unselect')">
          Unselect all
        </button>
        <button
          @click="$emit('import')"
          :disabled="disabled"
          class="button normal-input button-submit">
          Import
        </button>
      </div>
    </div>
  </navbar-component>
</template>

<script>

import NavbarComponent from 'components/navBar'

export default {
  components: {
    NavbarComponent
  },
  props: {
    pagination: {
      type: Object,
      default: undefined
    },
    disabled: {
      type: Boolean,
      default: false
    },
    rowsCount: {
      type: [String, Number],
      default: 0
    }
  }
}
</script>
