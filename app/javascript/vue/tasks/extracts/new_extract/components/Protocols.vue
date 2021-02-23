<template>
  <div>
    <h2>Protocols</h2>
    <smart-selector
      model="protocols"
      klass="extract"/>
    <lock-component v-model="settings.lock.protocol"/>
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
