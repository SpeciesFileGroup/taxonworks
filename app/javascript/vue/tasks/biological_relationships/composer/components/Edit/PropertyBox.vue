<template>
  <div class="panel content relationship-box horizontal-left-content item middle">
    <span v-if="!properties.length">Drop property</span>
    <draggable
      v-model="properties"
      :group="{ name: 'property', put: true }"
      class="item item1 column-medium flex-wrap-column full_width middle">
      <span
        class="pill property"
        v-for="item in properties"
        v-html="item.name"/>
    </draggable>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'

export default {
  components: {
    Draggable
  },
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    properties: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      property: []
    }
  }
}
</script>

<style lang="scss" scoped>
  .relationship-box {
    width: 200px;
    min-height: 80px;
    max-width: 200px;
  }
</style>