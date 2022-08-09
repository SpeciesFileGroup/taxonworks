<template>
  <ul class="tree">
    <template
      v-for="taxon in list"
      :key="taxon.id">
      <li v-if="currentTaxonId === taxon.parent_id && checkFilter(taxon)">
        <a :href="`/tasks/otus/browse?taxon_name_id=${taxon.id}`">
          <span v-html="taxon.object_tag"/>
        </a>
        <span>{{ taxon.cached_is_valid ? '✓' : '❌' }}</span>
        <tree-view
          v-if="list.find(child => taxon.id === child.parent_id)"
          :current-taxon-id="taxon.id"
          :list="list"/>
      </li>
    </template>
  </ul>
</template>

<script>

import TreeView from './TreeView'

export default {
  name: 'TreeView',

  components: {
    TreeView
  },

  props: {
    list: {
      type: Array,
      default: () => []
    },
    currentTaxonId: {
      type: Number,
      required: true
    },
    onlyValid: {
      type: Boolean,
      default: false
    }
  },

  methods: {
    getChilds (taxon) {
      return this.list.filter(item => taxon.id === item.parent_id)
    },

    checkFilter (taxon) {
      return this.onlyValid
        ? taxon.cached_is_valid
        : true
    }
  }
}
</script>
