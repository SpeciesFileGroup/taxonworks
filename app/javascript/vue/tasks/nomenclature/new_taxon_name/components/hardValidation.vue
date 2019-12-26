<template>
  <div>
    <div :class="{ field_with_errors : existError(field) }">
      <slot name="body"/>
    </div>
    <ul class="hardValidation no_bullets">
      <li
        class="hardValidation"
        v-for="error in displayError(field)"
        v-html="error"/>
    </ul>
  </div>
</template>
<script>

import { GetterNames } from '../store/getters/getters'

export default {
  props: {
    field: {
      type: String,
      required: true
    }
  },
  computed: {
    errors () {
      return this.$store.getters[GetterNames.GetHardValidation]
    }
  },
  methods: {
    existError: function (type) {
      return (this.errors && this.errors.hasOwnProperty(type))
    },
    displayError (type) {
      if (this.existError(type)) {
        return this.errors[type]
      } else {
        return undefined
      }
    }
  }
}
</script>
