<template>
  <div class="lep_stage">
    <div class="horizontal-left-content row">
      <div class="section-box box-0">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[0]"
        />
      </div>
      <div class="section-box box-1">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[1]"
        />
      </div>
      <div class="section-box box-2">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[2]"
        />
      </div>
    </div>
    <div class="horizontal-left-content">
      <div class="section-box box-6">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[6]"
        />
      </div>
      <div>
        <div class="section-box box-5">
          <select-component
            :layout-types="layoutTypes"
            v-model="newType[5]"
          />
        </div>
        <div class="section-box box-4">
          <select-component
            :layout-types="layoutTypes"
            v-model="newType[4]"
          />
        </div>
      </div>
      <div class="section-box box-3">
        <select-component
          :layout-types="layoutTypes"
          v-model="newType[3]"
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
.lep_stage {
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

  .row {
    margin-bottom: 10px;
  }

  .box-0 {
    margin-right: 5px;
  }

  .box-1 {
    margin-right: 5px;
    margin-left: 5px;
  }

  .box-6 {
    height: 372px;
    margin-right: 5px;
  }

  .box-2 {
    margin-left: 5px;
  }

  .box-3 {
    height: 372px;
    margin-left: 5px;
  }

  .box-5 {
    margin-left: 5px;
    margin-right: 5px;
  }

  .box-4 {
    margin-top: 10px;
    margin-left: 5px;
  }
}
</style>
