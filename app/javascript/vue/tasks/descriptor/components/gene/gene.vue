<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Gene attributes</h3>
    </div>
    <div class="body">
      <div class="separate-bottom">
        <instance-component
          title="Reverse primer"
          v-model="descriptor"
          @save="$emit('save', $event)"/>
      </div>
    </div>
  </div>
</template>
<script>

import InstanceComponent from './instance'

export default {
  components: {
    InstanceComponent
  },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    descriptor: {
      get () {
        return this.value
      },
      set () {
        this.$emit('input', this.value)
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