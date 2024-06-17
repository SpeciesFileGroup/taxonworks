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
          v-model="container.name"
        />
      </div>
      <ContainerType
        :types="types"
        v-model="container"
      />
      <ContainerParent
        v-if="validParents"
        :types="types"
        v-model="container.parentId"
      />
      <ContainerSize
        v-model="container.size"
        :disabled="!!type.dimensions"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Container } from '@/routes/endpoints'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ContainerParent from './ContainerParent.vue'
import ContainerType from './ContainerType.vue'
import ContainerSize from './ContainerSize.vue'

const container = defineModel({
  type: Object,
  required: true
})

const type = ref({})
const types = ref([])

const validParents = computed(() => {
  const type = types.value.find((item) => item.type === container.value.type)

  return type?.valid_parents
})

Container.types().then(({ body }) => {
  types.value = body
})
</script>
