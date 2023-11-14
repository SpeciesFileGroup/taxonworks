<template>
  <div class="panel content">
    <h2>Summary</h2>
    <div class="horizontal-left-content">
      <button
        @click="store.saveCollectionObject()"
        type="button"
        class="button button-input button-submit margin-medium-right full_width"
      >
        {{ 'Create' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import useStore from '../store/store'

const emit = defineEmits(['update'])
const store = useStore()
</script>

<style scoped>
.button-input {
  min-height: 28px;
}
</style>
