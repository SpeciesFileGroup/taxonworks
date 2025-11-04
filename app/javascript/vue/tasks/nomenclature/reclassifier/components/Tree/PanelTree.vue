<template>
  <BlockLayout>
    <template #header>
      <h3>Taxonomic tree</h3>
    </template>
    <template #options>
      <VBtn
        color="primary"
        circle
        title="Synchronize this tree with the other panel"
        @click="() => emit('sync')"
      >
        <VIcon
          name="synchronize"
          x-small
        />
      </VBtn>
    </template>
    <template #body>
      <div class="panel-container">
        <div
          class="horizontal-left-content middle flex-separate gap-small margin-medium-bottom"
        >
          <Autocomplete
            class="full_width"
            url="/taxon_names/autocomplete"
            placeholder="Search a taxon name..."
            label="label_html"
            clear-after
            param="term"
            @select="({ id }) => emit('load', id)"
          />
          <ButtonPinned
            section="TaxonNames"
            :type="TAXON_NAME"
            @get-id="(id) => emit('load', id)"
          />
        </div>
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
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import { TAXON_NAME } from '@/constants'

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

const emit = defineEmits(['load', 'sync'])

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
