<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Gene attributes</h3>
    </div>
    <div class="body">
      <div class="separate-bottom">
        <instance-component title="Reverse primer"/>
      </div>
      <button
        type="button"
        class="button normal-input button-submit separate-top">
        Create
      </button>
    </div>
  </div>
</template>
<script>

import PrimerComponent from './primer'
import InstanceComponent from './instance'

export default {
  components: {
    PrimerComponent,
    InstanceComponent
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