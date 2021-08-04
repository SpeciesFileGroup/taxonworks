<template>
  <div>
    <h1>Biological relationship composer</h1>
    <div class="flex-separate">
      <biological-relationships
        class="tables-relationship-properties"
        ref="biological"
        @selected="setBiologicalRelationship"/>
      <div class="margin-medium-left margin-medium-right ">
        <edit-component
          class="full_width"
          :biological-relationship="selected"
          @update="addRelationship"/>
      </div>
      <properties-component class="tables-relationship-properties"/>
    </div>
  </div>
</template>

<script>

import BiologicalRelationships from './components/BiologicalRelationships/Main'
import PropertiesComponent from './components/Properties/Main'
import EditComponent from './components/Edit/Main'

export default {
  components: {
    BiologicalRelationships,
    EditComponent,
    PropertiesComponent
  },

  data () {
    return {
      selected: undefined
    }
  },

  methods: {
    setBiologicalRelationship (value) {
      this.selected = value
    },

    addRelationship (item) {
      this.$refs.biological.addRelationship(item)
    }
  }
}
</script>
<style lang="scss" scoped>
  .tables-relationship-properties {
    min-width: 280px;
  }
</style>
