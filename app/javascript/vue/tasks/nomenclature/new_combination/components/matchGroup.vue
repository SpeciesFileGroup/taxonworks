<template>
  <div class="new-combination-rank-list">
    <div class="header">
      <h3 class="flex-separate">
        <span class="capitalize">{{ rankName }}</span>
      </h3>
    </div>
    <ul>
      <li
        class="no_bullets horizontal-left-content"
        v-for="taxon in inOrder(list)">
        <span
          class="new-combination-rank-list-taxon-name"
          v-html="taxon.object_tag"/>
          <div class="horizontal-left-content separate-left">
            <radial-annotator 
              type="annotator"
              :global-id="taxon.global_id"/>
            <a
              target="_blank"
              :href="`/tasks/nomenclature/new_taxon_name/${taxon.id}`"
              class="circle-button btn-edit"/>
          </div>
      </li>
    </ul>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'

export default {
  components: {
    RadialAnnotator
  },
  props: {
    list: {
      type: Array,
      required: true
    },
    rankName: {
      type: String,
      required: true
    }
  },
  methods: {
    inOrder (list) {
      const newOrder = list.slice(0)
      newOrder.sort((a, b) => {
        if (a.original_combination < b.original_combination) { return -1 }
        if (a.original_combination > b.original_combination) { return 1 }
        return 0
      })
      return newOrder
    }
  }
}
</script>
<style lang="scss">
  .new-combination-rank-list {
    transition: all 0.5 ease;
    display: flex;
    flex-direction: column;
    .header {
      padding: 1em;
      border-bottom: 1px solid #f5f5f5;
      h3 {
        font-weight: 300;
      }
    }
  }
</style>