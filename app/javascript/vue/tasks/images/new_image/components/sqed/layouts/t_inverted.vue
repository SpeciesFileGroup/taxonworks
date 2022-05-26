<template>
  <div class="t">
    <div class="horizontal-left-content row">
      <div class="section-box box-0">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[0]"/>
      </div>
      <div class="section-box box-1">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[1]"/>
      </div>
    </div>
    <div class="horizontal-left-content">
      <div class="section-box box-double-size box-3">
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
  .t {
    .section-box {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 200px;
      height: 150px;
      padding: 30px;
      border: 1px solid gray;
      border-radius: 3px;
      background-color: #FFFFFF;
    }

    .row {
      margin-bottom: 10px;
    }

    .box-0 {
      margin-right: 5px;
    }

    .box-1 {
      margin-left: 5px;
    }

    .box-3 {
      height: 372px;
    }

    .box-double-size {
      width: 472px;
      height: 150px;
    }
  }
</style>
