<template>
  <div>
    <div class="separate-bottom">
      <instance-component
        title="Reverse primer"
        v-model="descriptor"
        @save="$emit('save', $event)"/>
    </div>
  </div>
</template>
<script>

import InstanceComponent from './instance'

export default {
  components: { InstanceComponent },

  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    descriptor: {
      get () {
        return this.modelValue
      },
      set () {
        this.$emit('update:modelValue', this.value)
      }
    }
  },

  data () {
    return {
      tabs: [],
      lists: [],
      view: undefined,
      sequences: []
    }
  }
}
</script>
<style scoped>
  .character-input {
    width: 40px !important;
  }
</style>