<template>
  <li class="cursor-grab">
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
      class="list-reclassifer-taxon-item"
      v-html="taxon.name"
    />

    <template v-if="(!taxon.isLoaded || taxon.isExpanded) && taxon.children">
      <VDraggable
        class="taxonomy-tree"
        item-key="id"
        :group="group"
        v-model="taxon.children"
        tag="ul"
        :sort="false"
        :data-parent-id="taxon.id"
        :data-tree="group.name"
        @add="handleAdd"
        @choose="handleChoose"
      >
        <template #item="{ element }">
          <TreeNode
            :taxon="element"
            :group="group"
            :data-parent-id="taxon.id"
            :data-taxon-id="element.id"
            :only-valid="onlyValid"
            :tree="tree"
            :target="target"
          />
        </template>
      </VDraggable>
    </template>
  </li>
</template>

<script setup>
import { ref, toRaw, nextTick } from 'vue'
import { TaxonName } from '@/routes/endpoints'
import { findNodeById, removeNode } from '../../utils'
import TreeNode from './TreeNode.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VDraggable from 'vuedraggable'
import useStore from '../../store/store.js'

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
  },

  tree: {
    type: Object,
    required: true
  },

  target: {
    type: Array,
    required: true
  }
})

const isLoading = ref(false)
const store = useStore()

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

function handleChoose(e) {
  store.setCurrentDraggedItem({
    parent: props.taxon,
    item: props.taxon.children[e.oldIndex],
    index: e.oldIndex
  })
}

function reasignNode(parentId, index) {
  const targetParent = findNodeById(props.target, parentId)

  if (targetParent) {
    targetParent.children.splice(index, 0, {
      ...structuredClone(toRaw(store.currentDragged.item)),
      parentId: parentId
    })
  }
}

function handleAdd(e) {
  const { newIndex } = e
  const movedTaxon = props.taxon.children[newIndex]
  const payload = {
    taxon_name: { parent_id: props.taxon.id }
  }

  TaxonName.update(movedTaxon.id, payload)
    .then(({ body }) => {
      const newName = [body.cached_html, body.cached_author_year].join(' ')

      removeNode(props.tree, {
        id: movedTaxon.id,
        parentId: movedTaxon.parentId
      })

      Object.assign(movedTaxon, {
        parentId: body.parent_id,
        name: newName
      })

      reasignNode(movedTaxon.parentId, newIndex)

      TW.workbench.alert.create(`${newName} was reclassified to successfully`)
    })
    .catch(() => {
      props.taxon.children.splice(newIndex, 1)
      store.currentDragged.parent.children.splice(
        store.currentDragged.index,
        0,
        movedTaxon
      )
    })
}
</script>

<style scoped>
.list-reclassifer-taxon-item {
  border: 2px dashed transparent;
}

.list-reclassifer-taxon-item:hover {
  border-color: var(--color-primary);
}

.sortable-ghost {
  .list-reclassifer-taxon-item:hover {
    border: 2px dashed transparent;
  }
  .list-reclassifer-taxon-item {
    border: 2px dashed var(--color-update);
  }
}
</style>
