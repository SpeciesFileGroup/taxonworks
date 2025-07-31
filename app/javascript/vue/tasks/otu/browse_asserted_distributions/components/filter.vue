<template>
  <BlockLayout>
    <template #header>
      <h3>OTU</h3>
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
      <div>
        <span>Name</span>
        <VAutocomplete
          url="/otus/autocomplete"
          placeholder="Search an OTU"
          param="term"
          label="label_html"
          autofocus
          clear-after
          @get-item="
            (item) => {
              parameters.otu_id = item.id
              emit('select', { otu_id: item.id })
            }
          "
        />
      </div>
      <OtuLinks :otu-id="parameters.otu_id" />
    </template>
  </BlockLayout>
</template>

<script setup>
import OtuLinks from './navBar'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'

const emit = defineEmits(['select'])

const parameters = defineModel({
  type: Object,
  required: true
})

function resetFilter() {
  emit('reset')
}
</script>
<style scoped>
:deep(.btn-delete) {
  background-color: var(--color-primary);
}
</style>
