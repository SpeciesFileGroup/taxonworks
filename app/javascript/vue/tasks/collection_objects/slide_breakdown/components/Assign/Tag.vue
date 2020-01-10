<template>
  <fieldset>
    <legend>Tag</legend>
    <smart-selector
      model="keywords"
      klass="CollectionObject"/>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  }
}
</script>

<style>

</style>