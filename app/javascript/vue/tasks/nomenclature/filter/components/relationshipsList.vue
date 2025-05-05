<template>
  <transition-group
    class="table-entrys-list"
    name="list-complete"
    tag="ul"
  >
    <li
      v-for="(item, key) in list"
      :key="item.type + item.taxonId"
      class="list-complete-item flex-separate middle"
    >
      <span>
        <span v-html="item.taxon_label" /> <span v-html="item.type_label" /> (?)
      </span>
      <div class="list-controls">
        <button
          type="button"
          class="button button-default normal-input"
          @click="flipItem(item)"
        >
          Flip
        </button>
        <span
          class="circle-button btn-delete"
          @click="deleteItem(key)"
          >Remove
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
      default: () => []
    }
  },

  emits: ['delete', 'flip'],

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
