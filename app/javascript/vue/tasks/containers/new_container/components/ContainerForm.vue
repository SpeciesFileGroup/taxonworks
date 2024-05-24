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
      <div class="field">
        <label>Parent</label>
        <VAutocomplete
          url="/containers/autocomplete"
          param="term"
          @get-item="setParent"
        />
      </div>
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
      <div class="horizontal-left-content gap-small">
        <VBtn
          color="create"
          medium
          @click="emit('save')"
        >
          {{ container.id ? 'Update' : 'Create' }}
        </VBtn>
        <VBtn
          color="primary"
          medium
          @click="emit('new')"
        >
          New
        </VBtn>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref } from 'vue'
import { vBetweenNumbers } from '@/directives'
import VBtn from '@/components/ui/VBtn/index.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
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

const emit = defineEmits(['save', 'new'])

const parent = ref(null)

function setParent(newParent) {
  parent.value = newParent
  container.value.parent_id = newParent?.id || null
}
</script>

<style scoped>
input[type='number'] {
  width: 60px;
}
</style>
