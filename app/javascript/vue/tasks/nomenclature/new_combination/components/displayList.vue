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
      <div class="horizontal-right-content">
        <placement-component
          class="margin-small-right"
          @created="$emit('placement', item)"
          :combination="item"/>
        <confidence-button
          :global-id="item.global_id"/>
        <radial-annotator
          :global-id="item.global_id"/>
        <v-btn
          class="margin-small-right"
          color="update"
          circle
          @click="$emit('edit', Object.assign({}, item))"
        >
          <v-icon
            x-small
            title="Edit"
            color="white"
            name="pencil"
          />
        </v-btn>
        <v-btn
          color="destroy"
          circle
          @click="$emit('delete', item)"
        >
          <v-icon
            x-small
            title="Remove"
            color="white"
            name="trash"
          />
        </v-btn>
      </div>
    </li>
  </transition-group>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import PlacementComponent from './placement.vue'
import ConfidenceButton from 'components/defaultConfidence'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

export default {
  components: {
    RadialAnnotator,
    PlacementComponent,
    ConfidenceButton,
    VBtn,
    VIcon
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
    padding: 1em 0;
    border: 0px;
    border-bottom: 1px solid #f5f5f5;
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
