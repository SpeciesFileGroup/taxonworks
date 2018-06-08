<template>
  <div>
    <block-verbatin/>
    <block-geography/>
  </div>
</template>

<script>

  import blockVerbatin from './components/verbatimLayout.vue'
  import blockGeography from './components/GeographyLayout.vue'

  export default {
    components: {
      blockVerbatin,
      blockGeography
    },
    data() {
      return {
        blocks: {
          
        }
      }
    }
  }
</script>