<template>
  <div>
    <spinner-component
      :show-spinner="false"
      :show-legend="false"
      v-if="spinner"/>
    <div class="panel basic-information">
      <a
        v-if="anchor"
        :name="anchor"
        class="anchor"/>
      <div class="header flex-separate middle">
        <slot name="header">
          <h3>Default title</h3>
        </slot>
        <expand-component v-model="expanded"/>
      </div>
      <div
        class="body"
        v-if="expanded">
        <slot name="body"/>
      </div>
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
    anchor: {
      type: String,
      default: undefined
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
