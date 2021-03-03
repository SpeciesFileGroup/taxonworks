<template>
  <div>
    <h2>Protocols</h2>
    <div class="horizontal-left-content align-start">
      <smart-selector
        class="full_width"
        model="protocols"
        klass="extract"/>
      <lock-component
        class="margin-small-left"
        v-model="settings.lock.protocol"/>
    </div>
  </div>
</template>

<script>

import LockComponent from 'components/lock'
import SmartSelector from 'components/smartSelector'
import componentExtend from './mixins/componentExtend'

export default {
  mixins: [componentExtend],
  components: {
    LockComponent,
    SmartSelector
  }
}
</script>
