<template>
  <div>
    <geography/>
    <elevation/>
  </div>
</template>
<script>

  import Geography from './geography/geography.vue'
  import Elevation from './geography/elevation.vue'

  export default {
    components: {
      Geography,
      Elevation
    }  
  }
</script>