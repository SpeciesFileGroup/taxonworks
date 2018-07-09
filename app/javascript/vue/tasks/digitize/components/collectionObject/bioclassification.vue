<template>
  <toggle-switch :biological-id="id"/>
</template>

<script>
  import ToggleSwitch from '../../../../type_specimens/components/toggleSwitch'
  export default {
    components: {
      ToggleSwitch
    },
    data() {
      return {
        id: undefined
      }
    }
  }
</script>
