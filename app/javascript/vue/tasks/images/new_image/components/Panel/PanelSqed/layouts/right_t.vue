<template>
  <div class="right_t horizontal-left-content">
    <div class="">
      <div class="section-box box-0">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[0]"/>
      </div>
    </div>
    <div class="">
      <div class="section-box box-1">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[1]"/>
      </div>
      <div class="section-box box-2">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[2]"/>
      </div>
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

    .box-0 {
      height: 372px;
      margin-right: 5px;
    }

    .box-1 {
      margin-left: 5px;
    }

    .box-2 {
      margin-left: 5px;
      margin-top: 10px;
    }
  }
</style>