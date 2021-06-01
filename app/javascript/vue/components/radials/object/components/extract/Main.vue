<template>
  <div>
    <smart-selector
      model="extracts"
      klass="CollectionObject"
    />
    <display-list
      :list="list"
      label="object_tag"
    />
  </div>
</template>

<script>

import CRUD from '../../request/crud'
import annotatorExtend from '../annotatorExtend'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from 'components/displayList.vue'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    SmartSelector,
    DisplayList
  },

  methods: {
    createExtract (item) {
      this.create({
        extract: {

        }
      })
    }
  }

}
</script>
