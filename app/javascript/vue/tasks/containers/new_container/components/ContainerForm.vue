<template>
  <BlockLayout>
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>Container</h3>
        <CloneButton />
      </div>
    </template>
    <template #body>
      <div class="field">
        <label class="d-block">Name</label>
        <input
          type="text"
          class="full_width"
          v-model="container.name"
          @change="() => (container.isUnsaved = true)"
        />
      </div>
      <ContainerType
        :types="types"
        v-model="container"
      />
      <ContainerParent
        v-if="validParents"
        :types="validParents"
        v-model="container.parentId"
      />
      <ContainerSize
        v-model="container.size"
        :disabled="!!dimensions"
        @change="() => (container.isUnsaved = true)"
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
import CloneButton from './CloneButton.vue'

const container = defineModel({
  type: Object,
  required: true
})

const types = ref([])

const validParents = computed(() => {
  const type = types.value.find((item) => item.type === container.value.type)

  return type?.valid_parents
})

const dimensions = computed(() => {
  const type = types.value.find((item) => item.type === container.value.type)

  return type?.dimensions
})

Container.types().then(({ body }) => {
  types.value = body
})
</script>
