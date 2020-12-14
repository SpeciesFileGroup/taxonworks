<template>
  <ul class="tree">
    <template v-for="taxon in list">
      <li
        v-if="currentTaxonId === taxon.parent_id && checkFilter(taxon)"
        :key="taxon.id">
        <a :href="`/tasks/otus/browse?taxon_name_id=${taxon.id}`">
          <span v-html="taxon.object_tag"/>
        </a>
        <span>{{ isValid(taxon) ? '✓' : '❌' }}</span>
        <tree-view
          v-if="list.find(child => { return taxon.id === child.parent_id })"
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
      default: () => { return [] }
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
      return this.list.filter(item => { return taxon.id === item.parent_id })
    },
    checkFilter (taxon) {
      return this.onlyValid ? taxon.id === taxon.cached_valid_taxon_name_id : true
    },
    isValid (taxon) {
      return taxon.id === taxon.cached_valid_taxon_name_id
    }
  }
}
</script>
