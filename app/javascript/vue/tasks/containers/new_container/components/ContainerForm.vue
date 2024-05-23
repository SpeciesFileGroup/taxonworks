<template>
  <BlockLayout>
    <template #header>
      <h3>Container</h3>
    </template>
    <template #body>
      <div class="field">
        <label class="d-block">Name</label>
        <input
          type="text"
          class="full_width"
          v-between-numbers="[1, 999]"
          v-model="container.name"
        />
      </div>
      <ContainerType v-model="container.type" />
      <div class="horizontal-left-content gap-small margin-medium-top">
        <div class="field">
          <label class="d-block">X</label>
          <input
            type="number"
            v-between-numbers="[1, 999]"
            v-model="container.sizeX"
          />
        </div>
        <div class="field">
          <label class="d-block">Y</label>
          <input
            type="number"
            v-between-numbers="[1, 999]"
            v-model="container.sizeY"
          />
        </div>
        <div class="field">
          <label class="d-block">Z</label>
          <input
            type="number"
            v-model="container.sizeZ"
          />
        </div>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { vBetweenNumbers } from '@/directives'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ContainerType from './ContainerType.vue'

const container = defineModel({
  type: Object,
  default: {
    name: '',
    sizeX: 0,
    sizeY: 0,
    sizeZ: 0
  }
})
</script>

<style scoped>
input[type='number'] {
  width: 60px;
}
</style>
