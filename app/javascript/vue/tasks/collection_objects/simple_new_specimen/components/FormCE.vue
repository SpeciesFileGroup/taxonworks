<template>
  <BlockLayout>
    <template #header>
      <h3>Collecting event</h3>
    </template>
    <template #body>
      <div class="field label-above">
        <label>Verbatim label</label>
        <textarea />
      </div>
      <div class="field label-above">
        <label>Verbatim label</label>
        <input
          type="text"
        >
      </div>
      <div class="field label-above">
        <label>Verbatim label</label>
        <textarea />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from 'components/layout/BlockLayout.vue'
</script>
