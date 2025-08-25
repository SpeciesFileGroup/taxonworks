<template>
  <label>
    <input
      type="checkbox"
      v-model="onlyValid"
      @change="updateStorage"
    />
    Show only valid names
  </label>

  <div class="panel-taxonomy-tree margin-medium-top">
    <ul
      class="taxonomy-tree"
      v-if="tree"
    >
      <TaxonomyTree
        :current-id="taxonId"
        :taxon="tree"
        :only-valid="onlyValid"
      />
    </ul>
  </div>
</template>

<script setup>
import { TaxonName } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'
import TaxonomyTree from './TaxonomyTree.vue'
import { convertType } from '@/helpers'

const STORAGE_ONLY_VALID_KEY = 'TW::TaxonomyTree::OnlyValid'

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
const onlyValid = ref(true)

function updateStorage() {
  localStorage.setItem(STORAGE_ONLY_VALID_KEY, onlyValid.value)
}

function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name: [taxon.cached_html, taxon.cached_author_year]
      .filter(Boolean)
      .join(' '),
    synonyms: taxon.synonyms,
    leaf: taxon.leaf_node,
    isExpanded: false,
    isValid: taxon.cached_is_valid,
    children: taxon.children?.map(makeTaxonNode) || []
  }
}

function buildTree(ancestors, taxon) {
  if (!ancestors || ancestors.length === 0) {
    return makeTaxonNode(taxon)
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
  onlyValid.value = convertType(localStorage.getItem(STORAGE_ONLY_VALID_KEY))

  TaxonName.taxonomy(props.taxonId).then(({ body }) => {
    tree.value = buildTree(body.ancestors, {
      ...body.taxon_name,
      synonyms: body.synonyms,
      children: body.children
    })
  })
})
</script>

<style lang="scss">
.sticky-navbar-fixed {
  .panel-taxonomy-tree {
    max-height: calc(100vh - 320px);
  }
}
.panel-taxonomy-tree {
  padding-left: 0.75em;
  max-height: calc(100vh - 500px);
  overflow-y: auto;
}
.taxonomy-tree {
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
    padding-left: 4px;
    border-left: 1px solid var(--border-color);
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
  }

  li:before {
    position: relative;
    top: -0.3em;
    height: 1em;
    width: 8px;
    color: white;
    border-bottom: 1px solid var(--border-color);
    content: '';
    display: inline-block;
    left: -4px;
  }

  li:last-child:before {
    border-left: 1px solid var(--border-color);
  }

  .synonym-list {
    list-style: none;
    padding-left: 8px;
    padding-bottom: 4px;

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
    color: var(--feedback-warning-text-color);
  }
}
</style>
