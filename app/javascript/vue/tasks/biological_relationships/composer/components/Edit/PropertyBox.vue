<template>
  <div
    class="panel content relationship-box horizontal-left-content item middle"
  >
    <span v-if="!properties.length">Drop property</span>
    <draggable
      v-model="properties"
      :group="{ name: 'property', put: true }"
      item-key="id"
      class="item item1 column-medium flex-wrap-column full_width"
    >
      <template #item="{ element, index }">
        <div
          v-if="!element._destroy"
          class="horizontal-left-content"
        >
          <span
            class="cursor-pointer button circle-button btn-delete"
            @click="removeProperty(index)"
          />
          <span
            v-html="
              element.biological_property?.object_tag || element.object_tag
            "
          />
        </div>
      </template>
    </draggable>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import Draggable from 'vuedraggable'

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const properties = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

function removeProperty(index) {
  if (properties.value[index]?.created) {
    properties.value[index]._destroy = true
  } else {
    properties.value.splice(index, 1)
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
