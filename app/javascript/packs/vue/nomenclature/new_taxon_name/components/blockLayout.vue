<template>
  <div>
    <spinner :show-spinner="false" :show-legend="false" v-if="spinner"/>
    <div class="panel basic-information">
      <a v-if="anchor" :name="anchor" class="anchor"/>
      <div class="header flex-separate middle">
        <slot name="header">
          <h3>Default title</h3>
        </slot>
        <expand @changed="expanded = !expanded" :expanded="expanded"/>
      </div>
      <div class="body" v-if="expanded">
        <slot name="body"/>
      </div>
    </div>
  </div>
</template>

<script>
const expand = require('./expand.vue').default
const spinner = require('../../../components/spinner.vue').default

export default {
  components: {
    expand,
    spinner
  },
  props: {
    anchor: {
      type: String,
      default: undefined
    },
    spinner: {
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
