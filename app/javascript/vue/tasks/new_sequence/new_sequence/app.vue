<template>
  <div>
    <div class="flex-separate">
      <h1>New sequence</h1>
      <div class="middle">
        <span
          class="cursor-pointer"
          data-icon="reset">Reset</span>
      </div>
    </div>
    <div class="panel content">
      <div class="horizontal-left-content">
        <type-sequence/>
        <bar-header/>
      </div>
    </div>
    <div class="panel content">
      <div class="horizontal-left-content align-start">
        <reverse-primer/>
        <import-sequence/>
      </div>
    </div>
  </div>
</template>

<script>

import ReversePrimer from './components/reversePrimer'
import TypeSequence from './components/typeSequence'
import BarHeader from './components/barHeader'
import ImportSequence from './components/importSequence'

export default {
  components: {
    ReversePrimer,
    TypeSequence,
    BarHeader,
    ImportSequence
  }
}
</script>