<template>
  <div class="flex-wrap-column margin-medium-left margin-medium-right">
    <div class="horizontal-left-content middle align-start" v-if="value">
      <template v-if="flip">
        <div class="margin-small-right">
          <label>Inverted name</label><br>
          <input
            type="text"
            v-model="biologicalRelationship.inverted_name">
        </div>
        <div>
          <label>Name</label><br>
          <p class="disabled margin-small-top" v-html="biologicalRelationship.name ? biologicalRelationship.name : '<i>None</i>'"/>
        </div>
      </template>
      <template v-else>
        <div class="margin-small-right">
          <label>Name</label><br>
          <input
            type="text"
            v-model="biologicalRelationship.name">
        </div>
        <div>
          <label>Inverted name</label><br>
          <p class="disabled margin-small-top" v-html="biologicalRelationship.inverted_name ? biologicalRelationship.inverted_name : '<i>None</i>'"/>
        </div>
      </template>
    </div>
    <template v-else>
      <div class="margin-medium-left margin-medium-right margin-medium-top">
        <input 
          type="text"
          disabled="true">
      </div>
    </template>

    <label>
      <input
        type="checkbox"
        v-model="biologicalRelationship.is_transitive">
        Is transitive
    </label>
    <label>
      <input
        type="checkbox"
        v-model="biologicalRelationship.is_reflexive">
        Is reflexive
    </label>
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