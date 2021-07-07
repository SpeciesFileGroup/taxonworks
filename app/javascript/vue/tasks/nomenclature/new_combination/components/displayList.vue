<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <li
      v-for="item in list"
      :key="item.id"
      class="list-complete-item flex-separate middle">
      <a
        :href="`/tasks/nomenclature/browse?taxon_name_id=${item.cached_valid_taxon_name_id}`"
        target="_blank"
        class="list-item"
      >
        <span v-html="composeName(item)" />
      </a>
      <div class="list-controls">
        <placement-component
          @created="$emit('placement', item)"
          :combination="item"/>
        <confidence-button
          :global-id="item.global_id"/>
        <radial-annotator
          :global-id="item.global_id"/>
        <span
          class="circle-button btn-edit"
          @click="$emit('edit', Object.assign({}, item))">Edit
        </span>
        <span
          class="circle-button btn-delete"
          @click="$emit('delete', item)">Remove
        </span>
      </div>
    </li>
  </transition-group>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import PlacementComponent from './placement.vue'
import ConfidenceButton from 'components/defaultConfidence'

export default {
  components: {
    RadialAnnotator,
    PlacementComponent,
    ConfidenceButton
  },

  props: {
    list: {
      type: Array,
      default: () => []
    }
  },

  emits: [
    'placement',
    'edit',
    'delete'
  ],

  methods: {
    composeName (taxon) {
      return `${taxon.cached_html} ${taxon.cached_author_year || ''}`
    }
  }
}
</script>
<style lang="scss" scoped>

.list-controls {
  display: flex;
  align-items:center;
  flex-direction:row;
  justify-content: flex-end;
  .circle-button {
    margin-left: 4px !important;
  }
}

.list-item {
  text-decoration: none;
  padding-left: 4px;
  padding-right: 4px;
}
.table-entrys-list {
  padding: 0px;
  position: relative;

  li {
    margin: 0px;
    padding: 6px;
    border: 0px;
    border-top: 1px solid #f5f5f5;
  }
}
.list-complete-item {
  justify-content: space-between;
  transition: all 0.5s, opacity 0.2s;
}
.list-complete-enter, .list-complete-leave-to
{
  opacity: 0;
  font-size: 0px;
  border:none;
  transform: scale(0.0);
}
.list-complete-leave-active {
  width: 100%;
  position: absolute;
}
</style>
