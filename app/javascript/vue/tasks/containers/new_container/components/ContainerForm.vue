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
      <ContainerType v-model="type" />
      <div class="field">
        <label>Parent</label>
        <VAutocomplete
          url="/containers/autocomplete"
          param="term"
          @get-item="setParent"
        />
      </div>
      <ContainerSize
        v-model="container.size"
        :disabled="!!type.dimensions"
      />
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
import { ref, watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ContainerType from './ContainerType.vue'
import ContainerSize from './ContainerSize.vue'

const container = defineModel({
  type: Object,
  required: true
})

const emit = defineEmits(['save', 'new'])
const parent = ref(null)
const type = ref({})

watch(type, (newVal) => {
  container.value.type = newVal.type

  container.value.size = {
    x: 0,
    y: 0,
    z: 0,
    ...newVal.dimensions
  }
})

function setParent(newParent) {
  parent.value = newParent
  container.value.parent_id = newParent?.id || null
}
</script>
