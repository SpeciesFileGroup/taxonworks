<template>
  <Teleport to="#navigate-options">
    <TaxonomyOptions
      v-model:only-valid="onlyValid"
      v-model:rainbow="rainbow"
    />
  </Teleport>

  <div class="panel-taxonomy-tree margin-medium-top">
    <VSpinner
      v-if="isLoading"
      legend="Loading taxonimic tree..."
    />
    <ul
      class="taxonomy-tree"
      v-if="tree"
    >
      <TaxonomyTree
        :current-id="taxonId"
        :taxon="tree"
        :rainbow="rainbow"
        :only-valid="onlyValid"
      />
    </ul>
  </div>
</template>

<script setup>
import { TaxonName } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'
import TaxonomyOptions from './TaxonomyOptions.vue'
import { makeTaxonNode } from '../../utils/makeTaxonNode'
import TaxonomyTree from './TaxonomyTree.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineOptions({
  name: 'TaxonomyTree'
})

const props = defineProps({
  taxonId: {
    type: Number,
    required: true
  }
})

const tree = ref()
const rainbow = ref(true)
const isLoading = ref(true)
const onlyValid = ref(true)

function buildTree(ancestors, taxon) {
  if (!ancestors || ancestors.length === 0) {
    return { ...makeTaxonNode(taxon), isExpanded: true, isLoaded: true }
  }

  let root = makeTaxonNode(ancestors[0])
  let current = root

  for (let i = 1; i < ancestors.length; i++) {
    const node = makeTaxonNode(ancestors[i])

    current.children.push(node)
    current = node
  }

  current.children.push({
    ...makeTaxonNode(taxon),
    isExpanded: true,
    isLoaded: true
  })

  return root
}

onBeforeMount(() => {
  TaxonName.taxonomy(props.taxonId)
    .then(({ body }) => {
      tree.value = buildTree(body.ancestors, {
        ...body.taxon_name,
        children: body.descendants
      })
    })
    .finally(() => {
      isLoading.value = false
    })
})
</script>

<style lang="scss">
.sticky-navbar-fixed {
  .panel-taxonomy-tree {
    height: 100%;
    height: calc(100vh - 320px);
    max-height: calc(100vh - 320px);
  }
}
.panel-taxonomy-tree {
  padding-left: 0.75em;
  height: calc(100vh - 500px);
  max-height: calc(100vh - 400px);
  overflow-y: auto;
}
.taxonomy-tree {
  --taxonomic-tree-border: var(--border-color);
  white-space: nowrap;
  word-wrap: normal;
  list-style: none;
  margin: 0;
  padding: 0;

  ul {
    margin-left: 2px;
  }

  li {
    position: relative;
    margin: 0;
    padding: 0px;
    padding-left: 6px;
    padding-top: 1px;
    border-left: 1px solid var(--taxonomic-tree-border);
    white-space: normal;

    button {
      position: absolute;
      top: 1px;
      left: -8px;
    }

    .current {
      font-weight: bold;
    }
  }

  li:last-child {
    border-left: none;

    .synonym-list {
      border-left: 1px solid var(--taxonomic-tree-border);
    }
  }

  li:before {
    position: relative;
    top: -0.3em;
    height: 1em;
    width: 8px;
    color: white;
    padding-top: 1px;
    border-bottom: 1px solid var(--taxonomic-tree-border);
    content: '';
    display: inline-block;
    left: -6px;
  }

  li:last-child:before {
    border-left: 1px solid var(--taxonomic-tree-border);
  }

  .synonym-list {
    list-style: none;
    padding-left: 8px;
    padding-bottom: 4px;
    margin-top: -7px;
    padding-top: 8px;
    border-left: 1px solid var(--taxonomic-tree-border);

    li {
      border-left: none;
      padding-left: 0px;
    }

    li:before {
      border-bottom: none;
      padding-left: 6px;
      width: 0px;
    }

    li:last-child:before {
      border-left: none;
    }
  }

  .taxonomy-tree-invalid-name {
    color: var(--taxon-name-invalid-color);
  }

  .taxonomy-tree-valid-name {
    color: var(--taxon-name-valid-color);
  }

  .taxonomy-tree-status-tag {
    font-size: 10px;
  }
}
</style>
