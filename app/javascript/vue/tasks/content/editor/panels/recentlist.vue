<template>
  <div>
    <div class="slide-panel-category-header">{{ title }}</div>
    <ul class="slide-panel-category-content">
      <li
        v-for="item in items"
        @click="save(select, item)"
        class="slide-panel-category-item">
        <span v-html="item.object_tag"/>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import AjaxCall from 'helpers/ajaxCall'

export default {
  props: ['ajaxUrl', 'setItems', 'select', 'getItems', 'title'],
  name: 'RecentList',
  computed: {
    items () {
      return this.$store.getters[GetterNames.GetRecent](this.getItems)
    }
  },
  mounted () {
    AjaxCall('get', this.ajaxUrl).then(response => {
      this.$store.commit(MutationNames[this.setItems], response.body)
    })
  },
  methods: {
    save (saveMethod, item) {
      this.$store.commit(MutationNames[saveMethod], item)
    }
  }
}
</script>
