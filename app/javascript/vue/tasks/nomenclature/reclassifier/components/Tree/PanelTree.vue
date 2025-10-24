<template>
  <BlockLayout>
    <template #header>
      <h3>Taxonomic tree</h3>
    </template>
    <template #body>
      <div class="panel-taxonomy-tree">
        <ul class="taxonomy-tree">
          <TreeNode
            v-for="taxon in tree"
            :group="group"
            :key="taxon.id"
            :taxon="taxon"
          />
        </ul>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import TreeNode from './TreeNode.vue'

const props = defineProps({
  group: {
    type: Object,
    required: true
  }
})

const tree = defineModel({
  type: Array,
  required: true
})
</script>
