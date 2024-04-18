<template>
  <div class="panel block-layout">
    <VSpinner
      :show-spinner="false"
      :show-legend="false"
      v-if="spinner"
    />
    <a
      v-if="anchor"
      :name="anchor"
      class="anchor"
    />
    <div
      class="header flex-separate middle"
      :class="{ 'validation-warning': warning }"
    >
      <slot name="header">
        <h3>Default title</h3>
      </slot>
      <div class="horizontal-left-content">
        <slot name="options" />
        <VExpand
          v-if="expand"
          v-model="expanded"
        />
      </div>
    </div>
    <div
      class="body"
      v-show="expanded"
    >
      <slot name="body" />
    </div>
  </div>
</template>

<script setup>
import VExpand from '@/components/expand.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { ref, watch } from 'vue'

const props = defineProps({
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
  },

  setExpanded: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['expandedChanged'])

const expanded = ref(props.setExpanded)

watch(
  () => props.setExpanded,
  () => {
    expanded.value = props.setExpanded
  }
)

watch(
  expanded,
  (newVal) => { emit('expandedChanged', newVal) }
)

</script>
<style lang="scss" scoped>
.block-layout {
  border-top-left-radius: 0px;
  transition: all 1s;
  .validation-warning {
    border-left: 4px solid #ff8c00 !important;
  }
  .create-button {
    min-width: 100px;
  }

  height: 100%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  .header {
    border-left: 4px solid green;
    h3 {
      font-weight: 300;
    }
    padding: 1em;
    padding-left: 1.5em;
    border-bottom: 1px solid #f5f5f5;
  }
  .body {
    padding: 2em;
    padding-top: 1em;
    padding-bottom: 1em;
  }
  .taxonName-input,
  #error_explanation {
    width: 300px;
  }
}
</style>
