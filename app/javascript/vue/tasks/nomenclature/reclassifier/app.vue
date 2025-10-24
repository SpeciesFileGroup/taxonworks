<template>
  <h1>Taxon name reclassifier</h1>
  <div class="horizontal-left-content gap-medium align-start">
    <PanelTree
      class="full_width"
      :group="{
        name: 'tree-1',
        put: ['tree-2']
      }"
      v-model="tree"
    />
    <PanelTree
      class="full_width"
      :group="{
        name: 'tree-2',
        put: ['tree-1']
      }"
      v-model="tree"
    />
  </div>
</template>

<script setup>
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import { computed, ref, onMounted } from 'vue'
import { TaxonName } from '@/routes/endpoints'

import PanelTree from './components/Tree/PanelTree.vue'

defineOptions({
  name: 'TaxonNameReclassifierApp'
})

const { queryParam, queryValue } = useQueryParam()
const taxonNames = ref([])

function makeTaxonNodeWithState(taxon) {
  return {
    ...makeTaxonNode(taxon),
    isLoaded: false,
    isExpanded: true
  }
}

function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name: [taxon.cached_html, taxon.cached_author_year].join(' '),
    parentId: taxon.parent_id,
    isValid: taxon.cached_is_valid,
    synonyms: taxon.synonyms || [],
    children: []
  }
}

function buildTree(data) {
  const nodesById = new Map()

  data.forEach((item) => {
    nodesById.set(item.id, makeTaxonNodeWithState(item))
  })

  const roots = []

  data.forEach((item) => {
    const node = nodesById.get(item.id)

    if (item.parent_id === null) {
      roots.push(node)
    } else {
      const parent = nodesById.get(item.parent_id)
      if (parent) {
        parent.children.push(node)
      } else {
        roots.push(node)
      }
    }
  })

  return roots
}

const tree = ref([])

onMounted(() => {
  if (queryParam.value === 'taxon_name_query') {
    TaxonName.filter({ ...queryValue.value, ancestrify: true, per: 2000 }).then(
      ({ body }) => {
        taxonNames.value = body
        tree.value = buildTree(taxonNames.value)
      }
    )
  }
})
</script>

<style lang="scss">
#reclassifier_task {
  .taxonomy-tree {
    ul {
      margin-left: 12px;
    }

    li {
      padding-left: 6px;
    }
  }
}
</style>
