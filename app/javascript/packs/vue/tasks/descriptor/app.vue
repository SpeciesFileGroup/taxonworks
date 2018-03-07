<template>
  <div>
    <h1>New descriptor</h1>
    <type-component v-model="descriptor.type"/>
  </div>
</template>
<script>

  import TypeComponent from './components/type/type.vue'

  export default {
    components: {
      TypeComponent
    },
    data() {
      return {
        descriptor: {
          type: undefined
        }
      }
    }
  }
</script>