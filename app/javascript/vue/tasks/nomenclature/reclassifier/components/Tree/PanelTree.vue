<template>
  <BlockLayout>
    <template #header>
      <h3>Taxonomic tree</h3>
    </template>
    <template #body>
      <div class="panel-container">
        <Autocomplete
          url="/taxon_names/autocomplete"
          placeholder="Search a taxon name..."
          label="label_html"
          clear-after
          param="term"
          @select="({ id }) => emit('load', id)"
        />
        <div
          v-if="tree.length"
          class="panel-taxonomy-tree"
        >
          <ul class="taxonomy-tree">
            <TreeNode
              v-for="taxon in tree"
              :group="group"
              :key="taxon.id"
              :taxon="taxon"
              :tree="tree"
              :target="target"
            />
          </ul>
        </div>
        <div
          v-else
          class="taxonomic-tree-empty-message"
        >
          <h2>
            Search a taxon name, or open from “Filter taxon names” to load the
            tree.
          </h2>
        </div>
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
  },

  target: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['load'])

const tree = defineModel({
  type: Array,
  required: true
})
</script>

<style scoped>
.panel-container {
  height: calc(100vh - 300px);
}

.panel-taxonomy-tree {
  height: calc(100vh - 340px);
}

.taxonomic-tree-empty-message {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
</style>
