<template>
  <div class="panel content relationship-box horizontal-left-content item middle">
    <span v-if="!properties.length">Drop property</span>
    <draggable
      v-model="properties"
      :group="{ name: 'property', put: true }"
      class="item item1 column-medium flex-wrap-column full_width ">
      <div
        v-for="(item, index) in properties" class="horizontal-left-content"
        v-if="!item._destroy">
        <span
          class="cursor-pointer button circle-button btn-delete"
          @click="removeProperty(index)"/>
        <span
          v-html="item['biological_property'] ? item.biological_property.object_tag : item.object_tag"/>
      </div>
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
  },
  methods: {
    removeProperty(index) {
      if(this.properties[index]['created']) {
        this.$set(this.properties[index], '_destroy', true)
      }
      else {
        this.properties.splice(index, 1)
      }
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