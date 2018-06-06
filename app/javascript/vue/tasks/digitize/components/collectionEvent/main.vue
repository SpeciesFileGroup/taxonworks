<template>
  <div>
    <component
      v-for="block in blocks" 
      :is="block"/>
  </div>
</template>

<script>
  export default {
    components: {

    },
    data() {
      return {
        blocks: {
          
        }
      }
    }
  }
</script>