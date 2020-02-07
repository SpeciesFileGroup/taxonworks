<template>
  <div class="panel content relationship-box flex-wrap-column middle">
    <span v-if="!property.length">Drop property</span>
    <draggable
      v-model="property"
      @add="added"
      :group="{ name: 'property', put: true }"
      class="item item1 column-medium horizontal-center-content full_width middle">
      <span
        v-for="item in property"
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
      type: Object,
      default: undefined
    }
  },
  data () {
    return {
      property: []
    }
  },
  watch: {
    value(newVal) {
      if(newVal)
        this.property = [newVal]
      else
        this.property = []
    }
  },
  methods: {
    added (event) {
      if(this.property.length === 2)
        this.property.splice(0,1)
      this.$emit('input', this.property[0])
    }
  }
}
</script>

<style lang="scss" scoped>
  .relationship-box {
    width: 200px;
    height: 80px;
  }
</style>