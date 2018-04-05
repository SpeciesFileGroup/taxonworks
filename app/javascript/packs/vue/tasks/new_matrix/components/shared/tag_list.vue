<template>
  <div>
    <tag-item
      class="button-submit"
      v-for="(item, key) in list"
      :key="key"
      :item="item"
      display="object_tag"
      @select="sendItem"/>
  </div>
</template>
<script>

import TagItem from '../../../../components/tag_item.vue'

export default {
  components: {
    TagItem
  },
  props: {
    list: {
      type: Array,
      required: true
    }
  },
  methods: {
    sendItem(item) {
      this.$emit('send', item)
    }
  }
}
</script>

