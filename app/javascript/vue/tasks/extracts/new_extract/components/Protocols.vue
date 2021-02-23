<template>
  <div>
    <h2>Protocols</h2>
    <smart-selector
      :model="protocols"/>
    <lock-component v-model="settings.lock.protocol"/>
  </div>
</template>

<script>

import LockComponent from 'components/lock'
import SmartSelector from 'components/smartSelector'

export default {
  components: {
    LockComponent,
    SmartSelector
  }
}
</script>
