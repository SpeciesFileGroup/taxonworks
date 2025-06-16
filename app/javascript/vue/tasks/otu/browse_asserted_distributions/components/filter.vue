<template>
  <BlockLayout>
    <template #header>
      <h3>Object</h3>
    </template>

    <template #options>
      <VBtn
        color="primary"
        circle
        @click="resetFilter"
      >
        <VIcon
          name="reset"
          x-small
          title="Reset"
        />
      </VBtn>
    </template>

    <template #body>
      <AssertedDistributionObjectPicker
        minimal
        autofocus
        @select-object="(o) => objectSelected(o)"
      />
      <ObjectLinks
        :objectId="parameters.objectId"
        :objectType="parameters.objectType"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import AssertedDistributionObjectPicker from '@/components/ui/SmartSelector/AssertedDistributionObjectPicker.vue'
import ObjectLinks from './objectLinks.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { toSnakeCase } from '@/helpers'

const parameters = defineModel({
  type: Object,
  required: true
})

const emit = defineEmits(['select'])

function resetFilter() {
  emit('reset')
}

function objectSelected(o) {
  parameters.objectId = o.id
  parameters.objectType = o.objectType

  const model = toSnakeCase(o.objectType)
  const model_query_term = `${model}_id`
  emit('select', { [model_query_term]: item.id })
}

</script>

<style scoped>

</style>
