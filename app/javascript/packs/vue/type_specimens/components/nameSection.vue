<template>
  <div class="panel type-specimen-box">
    <div class="header flex-separate middle">
        <h3>Name</h3>
        <expand v-model="displayBody"></expand>
    </div>
    <div class="body" v-if="displayBody">
    </div>
  </div>
</template>

<script>

  import expand from './expand.vue';
  
  export default {
    components: {
      expand
    },
    data: function() {
      return {
        displayBody: true
      }
    }
  }
</script>