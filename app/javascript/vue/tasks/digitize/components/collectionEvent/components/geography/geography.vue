<template>
  <div>
    <smart-selector
      name="geography"
      v-model="view"
      :options="tabs"/>
  </div>
</template>

<script>

  import SmartSelector from '../../../../../../components/switch.vue'

  export default {
    components: {
      SmartSelector
    },
    data() {
      return {
        tabs: ['Quick', 'Look back', 'Search'],
        view: undefined
      }
    }
  }
</script>
