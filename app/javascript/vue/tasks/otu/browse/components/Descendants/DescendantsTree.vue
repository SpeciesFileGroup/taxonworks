<template>
  <ul class="tree-descendants">
    <li
      v-if="Object.keys(taxonomy).length"
      :key="taxonomy.otu_id"
    >
      <DescendantsExpand
        v-if="!taxonomy.leaf_node"
        v-model="isTreeVisible"
      />
      <a
        :href="`${RouteNames.BrowseOtu}?otu_id=${taxonomy.otu_id}`"
        v-html="taxonomy.name"
      />

      <ul
        v-if="descendants.length"
        class="tree-descendants"
      >
        <template
          v-for="item in descendants"
          :key="item.otu_id"
        >
          <DescendantsTree
            v-if="isTreeVisible"
            :taxonomy="item"
          />
        </template>
      </ul>
    </li>
  </ul>
</template>

<script setup>
import DescendantsTree from './DescendantsTree.vue'
import DescendantsExpand from './DescendantsExpand.vue'
import { Otu } from '@/routes/endpoints'
import { ref, watch } from 'vue'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  taxonomy: {
    type: Object,
    required: true
  },

  level: {
    type: Number,
    default: 1
  }
})

const isTreeVisible = ref(!!props.taxonomy.descendants.length)
const descendants = ref([...props.taxonomy.descendants])

watch(isTreeVisible, (newVal) => {
  if (newVal) {
    loadDescendants()
  }
})

function loadDescendants() {
  if (descendants.value.length) {
    return
  }
  Otu.taxonomy(props.taxonomy.otu_id, {
    max_descendants_depth: 1
  }).then(({ body }) => {
    descendants.value = body.descendants
  })
}
</script>

<style lang="scss" scoped>
.tree-descendants {
  list-style: none;
  margin: 0;
  padding: 0;
  margin-left: 0.45rem;
  margin-top: 2px;

  li {
    position: relative;
    margin: 0;
    padding: 0px 6px;
    border-left: 1px solid rgb(100, 100, 100);
  }

  li:last-child {
    border-left: none;
  }

  li:before {
    position: relative;
    top: -0.3em;
    height: 1em;
    width: 12px;
    color: white;
    border-bottom: 1px solid rgb(100, 100, 100);
    content: '';
    display: inline-block;
    left: -6px;
  }

  li:last-child:before {
    border-left: 1px solid rgb(100, 100, 100);
  }
}
</style>
