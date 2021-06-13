<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <li
      v-for="item in list"
      :key="item.id"
      class="list-complete-item flex-separate middle"
      :class="{ 'highlight': checkHighlight(item) }">
      <span
        class="list-item"
        v-html="displayName(item)"/>
      <div class="list-controls">
        <citations-count
          :target="targetCitations"
          :object="item"/>
        <radial-annotator
          v-if="annotator"
          :global-id="item.global_id"/>
        <span
          v-if="edit"
          class="circle-button btn-edit"
          @click="$emit('edit', Object.assign({}, item))">Edit
        </span>
        <span
          v-if="remove"
          class="circle-button btn-delete"
          @click="deleteItem(item)">Remove
        </span>
      </div>
    </li>
  </transition-group>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import CitationsCount from './citationsCount'

export default {
  components: {
    RadialAnnotator,
    CitationsCount
  },

  props: {
    list: {
      type: Array,
      default: () => []
    },

    targetCitations: {
      type: String,
      required: true
    },

    label: {
      type: [String, Array],
      required: true
    },

    edit: {
      type: Boolean,
      default: false
    },

    remove: {
      type: Boolean,
      default: true
    },

    annotator: {
      type: Boolean,
      default: false
    },

    highlight: {
      type: Object,
      default: undefined
    }
  },

  emits: [
    'delete',
    'edit'
  ],

  mounted () {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
  },

  methods: {
    displayName (item) {
      if (typeof this.label === 'string') {
        return item[this.label]
      } else {
        let tmp = item
        this.label.forEach(label => {
          tmp = tmp[label]
        })
        return tmp
      }
    },

    checkHighlight (item) {
      if (this.highlight) {
        return this.highlight.key
          ? item[this.highlight.key] === this.highlight.value
          : item === this.highlight.value
      }
      return false
    },

    deleteItem (item) {
      if (window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('delete', item)
      }
    }
  }
}
</script>
<style lang="scss" scoped>

  .list-controls {
    display: flex;
    align-items: center;
    flex-direction: row;
    justify-content: flex-end;
    .circle-button {
      margin-left: 4px !important;
    }
  }

  .highlight {
    background-color: #E3E8E3;
  }

  .list-item {
    white-space: normal;
    a {
      padding-left: 4px;
      padding-right: 4px;
    }
  }

  .table-entrys-list {
    overflow-y: scroll;
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

  .list-complete-enter, .list-complete-leave-to {
    opacity: 0;
    font-size: 0px;
    border: none;
    transform: scale(0.0);
  }

  .list-complete-leave-active {
    width: 100%;
    position: absolute;
  }
</style>