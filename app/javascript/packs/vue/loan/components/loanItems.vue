<template>
    <div class="panel loan-box">
      <div class="header flex-separate middle">
        <h3 class="">Loan items</h3>
        <expand v-model="displayBody"></expand>
      </div>
      <div class="body flex-separate" v-if="displayBody">
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