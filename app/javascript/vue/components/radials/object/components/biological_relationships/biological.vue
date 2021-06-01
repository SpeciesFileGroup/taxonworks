<template>
  <div>
    <fieldset>
      <legend>Biological relationship</legend>
      <smart-selector
        class="full_width"
        ref="smartSelector"
        model="biological_relationships"
        target="Otu"
        klass="Otu"
        pin-section="BiologicalRelationships"
        buttons
        inline
        label="name"
        pin-type="BiologicalRelationship"
        @selected="$emit('select', $event)"
        :custom-list="list"
        :lock-view="false"
      />
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import CRUD from '../../request/crud.js'

export default {
  mixins: [CRUD],
  components: {
    SmartSelector
  },
  data () {
    return {
      list: {
        all: []
      }
    }
  },
  created () {
    this.loadTabList()
  },
  methods: {
    loadTabList () {
      this.getList('/biological_relationships.json').then(response => {
        this.list = { all: response.body }
      })
    }
  }
}
</script>
