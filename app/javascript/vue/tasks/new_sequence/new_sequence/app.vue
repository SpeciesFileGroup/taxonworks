<template>
  <div class="main-layout">
    <div class="flex-separate">
      <h1>New sequence</h1>
      <div class="middle">
        <span
          class="cursor-pointer"
          data-icon="reset">Reset</span>
      </div>
    </div>
    <div class="panel content">
      <div class="flex-separate">
        <type-sequence/>
        <bar-header/>
      </div>
    </div>
    <div class="panel content">
      <div class="flex-separate align-start">
        <reverse-primer
          class="full_width separate-right"
          title="Reverse Primer"/>
        <import-sequence class="full_width separate-left separate-right"/>
        <reverse-primer
          class="full_width separate-left"
          title="Foward Primer"/>
      </div>
      <table-component :list="list"/>
      <div class="flex-separate">
        <sequence-origin/>
        <protocol-component/>
      </div>
    </div>
  </div>
</template>

<script>

import ReversePrimer from './components/reversePrimer'
import TypeSequence from './components/typeSequence'
import BarHeader from './components/barHeader'
import ImportSequence from './components/importSequence'
import TableComponent from './components/TableComponent'
import ProtocolComponent from './components/protocolComponent'
import SequenceOrigin from './components/sequenceOrigin'

export default {
  components: {
    ReversePrimer,
    TypeSequence,
    BarHeader,
    ImportSequence,
    TableComponent,
    ProtocolComponent,
    SequenceOrigin
  },
  data () {
    return {
      list: []
    }
  }
}
</script>
<style lang="scss" scoped>
  .main-layout {
    margin: 0 auto;
    width: 1240px;
  }
</style>
