<template>
  <div class="middle flex-wrap-column">
    <div class="margin-medium-left margin-medium-right margin-large-top flex-wrap-column middle" v-if="value">
      <template v-if="flip">
        <input
          type="text"
          v-model="biologicalRelationship.inverted_name">
        <br>
        <span class="disabled"> {{ biologicalRelationship.name }}</span>
      </template>
      <template v-else>
        <input
          type="text"
          v-model="biologicalRelationship.name">
        <br>
        <span class="disabled">{{ biologicalRelationship.inverted_name }}</span>
      </template>
    </div>
    <template v-else>
      <div class="margin-medium-left margin-medium-right margin-medium-top">
        <input 
          type="text"
          disabled="true">
      </div>
    </template>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: Object,
      default: undefined
    },
    flip: {
      type: Boolean,
      required: true
    }
  },
  computed: {
    biologicalRelationship: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>

<style>

</style>