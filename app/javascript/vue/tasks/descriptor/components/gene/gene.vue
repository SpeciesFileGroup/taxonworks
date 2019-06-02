<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Gene attributes</h3>
    </div>
    <div class="body">
      <div class="separate-bottom">
        <instance-component
          title="Reverse primer"
          :descriptor="descriptor"
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
    descriptor: {
      type: Object,
      required: true
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