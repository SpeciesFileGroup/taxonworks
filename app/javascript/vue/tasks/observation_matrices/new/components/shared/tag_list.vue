<template>
  <div>
    <template
      v-for="(item, key) in list"
      :key="key">
      <tag-item
        v-if="!isAlreadyCreated(item)"
        :item="item"
        display="object_tag"
        @select="sendItem"/>
    </template>
  </div>
</template>
<script>

import { GetterNames } from '../../store/getters/getters'
import TagItem from 'components/tag_item.vue'

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
  computed: {
    isRow() {
      return (this.$store.getters[GetterNames.GetMatrixView] == 'row' ? true : false) 
    },
    columnsListDynamic() {
      return this.$store.getters[GetterNames.GetMatrixColumnsDynamic]
    },
    rowsListDynamic() {
      return this.$store.getters[GetterNames.GetMatrixRowsDynamic]
    },
  },
  methods: {
    sendItem(item) {
      this.$emit('send', item)
    },
    isAlreadyCreated(item) {
      if(!Array.isArray(this.list)) return
      if(this.isRow) {
        return this.rowsListDynamic.find(value => { return value.controlled_vocabulary_term_id == item.id })
      }
      else {
        return this.columnsListDynamic.find(value => { return value.controlled_vocabulary_term_id == item.id })
      }
    }

  }
}
</script>

