<template>
  <button
    @click="sendItem(item.id)"
    type="button"
    class="normal-input button tag_button button-data"
    v-html="item[display]"/>
</template>

<script>
export default {
  props: {
    item: {
      type: Object,
      required: true
    },
    display: {
      type: String,
      required: true
    }
  },

  emits: ['select'],

  methods: {
    sendItem() {
      this.$emit('select', this.item);
    }
  }
}
</script>
