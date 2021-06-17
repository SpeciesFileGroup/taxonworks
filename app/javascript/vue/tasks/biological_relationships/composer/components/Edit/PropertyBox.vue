<template>
  <div class="panel content relationship-box horizontal-left-content item middle">
    <span v-if="!properties.length">Drop property</span>
    <draggable
      v-model="properties"
      :group="{ name: 'property', put: true }"
      class="item item1 column-medium flex-wrap-column full_width ">
      <template #item="{ element }">
        <div
          v-if="!element._destroy"
          class="horizontal-left-content">
          <span
            class="cursor-pointer button circle-button btn-delete"
            @click="removeProperty(index)"/>
          <span
            v-html="element['biological_property'] ? element.biological_property.object_tag : element.object_tag"/>
        </div>
      </template>
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
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    properties: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
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
      if (this.properties[index]['created']) {
        this.properties[index]['_destroy'] = true
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