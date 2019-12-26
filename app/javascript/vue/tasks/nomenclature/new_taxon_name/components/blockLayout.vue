<template>
  <div>
    <spinner
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
        <expand
          @changed="expanded = !expanded"
          :expanded="expanded"/>
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
import Expand from './expand.vue'
import Spinner from 'components/spinner.vue'

export default {
  components: {
    Expand,
    Spinner
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
  data: function () {
    return {
      expanded: true
    }
  }
}
</script>
