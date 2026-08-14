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
      :class="{ 'validation-warning': warning, [headerClass]: headerClass }"
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

  headerClass: {
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

watch(expanded, (newVal) => {
  emit('expandedChanged', newVal)
})
</script>
<style lang="scss" scoped>
.block-layout {
  box-sizing: border-box;
  display: flex;
  flex-direction: column;

  .validation-warning {
    border-left: 4px solid #ff8c00 !important;
  }

  .create-button {
    min-width: 100px;
  }

  .header {
    border-left: 4px solid green;
    padding: var(--spacing-sm) var(--spacing-xl);
    padding-left: calc(var(--spacing-xl) - 4px);
    border-bottom: 1px solid var(--border-color);
  }

  .body {
    padding: var(--spacing-xl);
    padding-top: var(--spacing-lg);
    padding-bottom: var(--spacing-lg);
  }

  .taxonName-input,
  #error_explanation {
    width: 300px;
  }
}
</style>
