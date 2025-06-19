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
        under-text
        @select-object="(o) => objectSelected(o)"
      />
      <ObjectLinks
        :object-id="parameters.asserted_distribution_object_id"
        :object-type="parameters.asserted_distribution_object_type"
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

const parameters = defineModel({
  type: Object,
  required: true
})

const emit = defineEmits(['select'])

function resetFilter() {
  emit('reset')
}

function objectSelected(o) {
  parameters.value.asserted_distribution_object_id = o.id
  parameters.value.asserted_distribution_object_type = o.objectType

  emit('select', {
    asserted_distribution_object_id: o.id,
    asserted_distribution_object_type: o.objectType
  })
}

</script>

<style scoped>

</style>
