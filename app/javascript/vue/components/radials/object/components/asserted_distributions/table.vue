<template>
  <div class="vue-table-container">
    <table class="vue-table">
      <thead>
        <tr>
          <th>Geographic area</th>
          <th>Type</th>
          <th>Parent</th>
          <th />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item"
        >
          <td>
            <span
              :class="{ absent: item.is_absent }"
              v-html="item.geographic_area.name"
            />
          </td>
          <td>
            <span> {{ item.geographic_area.geographic_area_type.name }} </span>
          </td>
          <td>
            <span> {{ item.geographic_area.parent.name }} </span>
          </td>
          <td class="vue-table-options">
            <citation-count
              :object="item"
              :values="item.citations"
              target="asserted_distributions"
            />
            <radial-annotator :global-id="item.global_id" />
            <span
              class="circle-button btn-edit"
              @click="$emit('edit', Object.assign({}, item))"
            />
            <span
              class="circle-button btn-delete"
              @click="deleteItem(item)"
            >Remove
            </span>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import CitationCount from '../shared/citationsCount.vue'

export default {
  components: {
    RadialAnnotator,
    CitationCount
  },

  props: {
    list: {
      type: Array,
      default: () => []
    }
  },

  emits: [
    'delete',
    'edit'
  ],

  methods: {
    deleteItem (item) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$emit('delete', item)
      }
    }
  }
}
</script>
<style lang="scss" scoped>
  .vue-table-container {
    padding: 0px;
    position: relative;
  }

  .vue-table {
    width: 100%;
    .vue-table-options {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
    }
    tr {
      cursor: default;
    }
  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
  }

  .list-complete-enter-active, .list-complete-leave-active {
    opacity: 0;
    font-size: 0px;
    border: none;
  }
  .absent {
    padding: 5px;
    border-radius: 3px;
    background-color: #000;
    color: #FFF;
  }
</style>
