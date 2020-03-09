<template>
  <div>
    <switch-component
      :options="tabs"
      v-model="view"/>
    <component
      :ids="ids"
      :is="`${view}Component`"/>
  </div>
</template>

<script>

import SwitchComponent from 'components/switch'
import TagComponent from './Assign/Tags'

export default {
  components: {
    SwitchComponent,
    TagComponent
  },
  props: {
    ids: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      tabs: ['Tag', 'Loan', 'Determination'],
      view: 'Tag'
    }
  }
}
</script>

<style>

</style>