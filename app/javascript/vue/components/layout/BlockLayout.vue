<template>
  <div class="panel block-layout">
    <spinner-component
      :show-spinner="false"
      :show-legend="false"
      v-if="spinner"/>
    <a
      v-if="anchor"
      :name="anchor"
      class="anchor"/>
    <div 
      class="header flex-separate middle"
      :class="{ 'validation-warning': warning }">
      <slot name="header">
        <h3>Default title</h3>
      </slot>
      <div class="horizontal-left-content">
        <slot name="options"/>
        <expand-component
          v-if="expand"
          v-model="expanded"/>
      </div>
    </div>
    <div
      class="body"
      v-show="expanded">
      <slot name="body"/>
    </div>
  </div>
</template>

<script>
import ExpandComponent from 'components/expand.vue'
import SpinnerComponent from 'components/spinner.vue'

export default {
  components: {
    ExpandComponent,
    SpinnerComponent
  },

  props: {
    expand: {
      type: Boolean,
      default: false
    },

    anchor: {
      type: String,
      default: undefined
    },

    warning: {
      type: Boolean,
      default: false
    },

    spinner: {
      type: Boolean,
      default: false
    }
  },

  data () {
    return {
      expanded: true
    }
  }
}
</script>
<style lang="scss" scoped>
.block-layout {
  border-top-left-radius: 0px;
  transition: all 1s;
  .validation-warning {
    border-left: 4px solid #ff8c00 !important;
  }
  .create-button {
    min-width: 100px;
  }

  height: 100%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  .header {
    border-left:4px solid green;
    h3 {
    font-weight: 300;
  }
  padding: 1em;
  padding-left: 1.5em;
  border-bottom: 1px solid #f5f5f5;
  }
  .body {
    padding: 2em;
    padding-top: 1em;
    padding-bottom: 1em;
  }
  .taxonName-input,#error_explanation {
    width: 300px;
  }
}
</style>
