<template>
  <div class="flex-wrap-column margin-medium-left margin-medium-right">
    <div class="horizontal-left-content middle align-start" v-if="modelValue">
      <template v-if="flip">
        <div class="margin-small-right label-above">
          <label>Inverted name</label>
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
        <div class="margin-small-right label-above">
          <label>Name</label>
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
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="checkbox"
            v-model="biologicalRelationship.is_transitive">
          Is transitive
        </label>
      </li>
      <li>
        <label>
          <input
            type="checkbox"
            v-model="biologicalRelationship.is_reflexive">
          Is reflexive
        </label>
      </li>
    </ul>
    <div class="field margin-small-top">
      <label>Definition</label>
      <textarea
        class="full_width margin-small-top"
        v-model="biologicalRelationship.definition"
        rows="5"/>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: Object,
      default: undefined
    },

    flip: {
      type: Boolean,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    biologicalRelationship: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
