<template>
  <div class="right_t">
    <div class="section-box">
      <select-component
        :layout-types="layoutTypes"
        v-model="newType[0]"
      />
    </div>
    <div class="section-box">
      <select-component
        :layout-types="layoutTypes"
        v-model="newType[1]" 
      />
    </div>
  </div>
</template>

<script>

import Layout from './shared/layout.js'

export default {
  mixins: [Layout],
}
</script>

<style lang="scss">
  .right_t {
    .section-box {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 150px;
      height: 150px;
      padding: 30px;
      border: 1px solid gray;
      border-radius: 3px;
      background-color: #FFFFFF;
    }
  }
</style>