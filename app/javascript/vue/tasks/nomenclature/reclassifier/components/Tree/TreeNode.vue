<template>
  <li>
    <VBtn
      v-if="!taxon.leaf"
      circle
      small
      color="primary"
      :disabled="isLoading"
      @click="toggle"
    >
      <span v-if="taxon.isLoaded && taxon.isExpanded">-</span>
      <span v-else>+</span>
    </VBtn>
    <span
      :class="{ 'taxonomy-tree-invalid-name': !taxon.isValid }"
      v-html="taxon.name"
    />

    <template v-if="(!taxon.isLoaded || taxon.isExpanded) && taxon.children">
      <VDraggable
        class="taxonomy-tree"
        item-key="id"
        :group="group"
        v-model="taxon.children"
        tag="ul"
        @add="handleAdd"
      >
        <template #item="{ element, index }">
          <TaxonomyTree
            :taxon="element"
            :group="group"
            :only-valid="onlyValid"
          />
        </template>
      </VDraggable>
    </template>
  </li>
</template>

<script setup>
import { computed, ref } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import TaxonomyTree from './TreeNode.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VDraggable from 'vuedraggable'

const props = defineProps({
  taxon: {
    type: Object,
    required: true
  },

  group: {
    type: Object,
    required: true
  },

  onlyValid: {
    type: Boolean,
    default: false
  }
})

const isLoading = ref(false)

function toggle() {
  if (!props.taxon.isLoaded) {
    expandNode(props.taxon.id)
  }

  props.taxon.isExpanded = !props.taxon.isExpanded
}

function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name: taxon.label,
    parentId: taxon.parent_id,
    isValid: taxon.is_valid,
    leaf: taxon.leaf_node,
    synonyms: taxon.synonyms || [],
    children: []
  }
}

function expandNode(taxonId) {
  isLoading.value = true
  TaxonName.taxonomy(taxonId, {
    ancestors: false,
    count: false
  })
    .then(({ body }) => {
      const children = body.descendants.map((c) => makeTaxonNode(c))

      children.forEach((item, index) => {
        const current = props.taxon.children.find((c) => c.id === item.id)

        if (current) {
          children[index] = current
        }
      })

      props.taxon.isExpanded = true
      props.taxon.isLoaded = true
      props.taxon.children = children
    })
    .finally(() => {
      isLoading.value = false
    })
}

function handleAdd(event) {
  const movedTaxon = props.taxon.children[event.newIndex]
  const payload = {
    taxon_name: { parent_id: props.taxon.id }
  }

  TaxonName.update(movedTaxon.id, payload)
    .then(({ body }) => {
      const newName = [body.cached_html, body.cached_author_year].join(' ')

      Object.assign(movedTaxon, {
        parentId: body.parent_id,
        name: newName
      })

      TW.workbench.alert.create(`${newName} was reclassified to successfully`)
    })
    .catch(() => {})
}
</script>
