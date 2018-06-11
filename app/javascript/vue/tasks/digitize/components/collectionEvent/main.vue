<template>
  <div class="horizontal-left-content align-start">
    <block-verbatin class="separate-right"/>
    <block-geography class="separate-left"/>
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