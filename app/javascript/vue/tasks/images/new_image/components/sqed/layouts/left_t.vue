<template>
  <div class="left_t horizontal-left-content">
    <div>
      <div class="section-box box-1">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[0]"
        />
      </div>
      <div class="section-box box-2">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[1]"
        />
      </div>
    </div>
    <div>
      <div class="section-box box-0">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[2]"
        />
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
.left_t {
  gap: 10px;
  .section-box {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 150px;
    height: 150px;
    padding: 30px;
    border: 1px solid gray;
    border-radius: 3px;
    background-color: #ffffff;
  }

  .box-0 {
    height: 372px;
  }

  .box-2 {
    margin-top: 10px;
  }
}
</style>
