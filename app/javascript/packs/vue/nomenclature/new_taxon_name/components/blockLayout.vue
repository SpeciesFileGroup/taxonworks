<template>
  <div class="panel basic-information">
    <a v-if="anchor" :name="anchor" class="anchor"></a>
    <div class="header flex-separate middle">
      <slot name="header">
        <h3>Default title</h3>
      </slot>
      <expand @changed="expanded = !expanded" :expanded="expanded"></expand>
    </div>
    <div class="body" v-if="expanded">
      <slot name="body">

      </slot>
    </div>
  </div>
</template>

<script>
  const expand = require('./expand.vue');

export default {
  components: {
    expand
  },
  props: {
    anchor: {
      type: String,
      default: undefined
    }
  },
  data: function() {
    return {
      expanded: true,
    }
  }
};
</script>