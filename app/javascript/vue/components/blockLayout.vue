<template>
  <div class="panel basic-information">
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
import ExpandComponent  from './expand.vue'
import SpinnerComponent from './spinner.vue'

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
  data() {
    return {
      expanded: true
    }
  }
}
</script>
