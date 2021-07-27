<template>
  <div class="horizontal_offset_cross">
    <div class="horizontal-left-content row">
      <div class="section-box">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[0]"/>
      </div>
      <div class="section-box">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[1]"/>
      </div>
    </div>
    <div class="horizontal-left-content">
      <div class="section-box box-2">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[3]"/>
      </div>
      <div class="section-box box-3">
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
  mixins: [Layout]
}
</script>

<style lang="scss">
  .horizontal_offset_cross {
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

    .row {
      margin-bottom: 10px;
      .section-box {
        height: 300px;
      }
    }

    .box-3 {
      width: 100px;
    }

    .box-2 {
      width: 200px;
    }

    .section-box:first-child {
      margin-right: 5px;
    } 
    .section-box:last-child {
      margin-left: 5px;
    }
  }
</style>