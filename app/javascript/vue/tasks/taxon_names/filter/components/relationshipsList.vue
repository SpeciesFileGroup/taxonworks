<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul">
    <li
      v-for="(item, key) in list"
      :key="item.type + item.taxonId"
      class="list-complete-item flex-separate middle">
      <span>
        <span v-html="item.taxon_label"/>
        <span v-html="item.type_label"/>
        <span>(?)</span>
      </span>
      <div class="list-controls">
        <button
          type="button"
          class="button button-default normal-input"
          @click="flipItem(item)">Flip</button>
        <span
          class="circle-button btn-delete"
          @click="deleteItem(key)">Remove
        </span>
      </div>
    </li>
  </transition-group>
</template>
<script>

export default {
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    },
  },
  methods: {
    deleteItem(key) {
      this.$emit('delete', key)
    },
    flipItem(item) {
      this.$emit('flip', item)
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