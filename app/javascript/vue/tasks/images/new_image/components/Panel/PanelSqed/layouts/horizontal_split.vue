<template>
  <div class="horizontal_split">
    <div class="section-box separate-bottom">
      <select-component
        :layout-types="layoutTypes"
        v-model="newType[0]"
      />
    </div>
    <div class="section-box separate-top">
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
  mixins: [Layout]
}
</script>

<style lang="scss">
.horizontal_split {
  display: block;
  .section-box {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 150px;
    height: 150px;
    padding: 30px;
    border: 1px solid gray;
    border-radius: 3px;
    background-color: var(--panel-bg-color);
  }
}
</style>
