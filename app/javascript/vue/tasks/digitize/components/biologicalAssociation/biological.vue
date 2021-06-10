<template>
  <fieldset class="full_width">
    <legend>Biological relationship</legend>
    <div class="horizontal-left-content middle margin-medium-bottom">
      <smart-selector
        class="full_width"
        ref="smartSelector"
        model="biological_relationships"
        target="CollectionObject"
        klass="CollectionObject"
        :add-tabs="['all']"
        pin-section="BiologicalRelationships"
        :buttons="true"
        :inline="true"
        label="name"
        pin-type="BiologicalRelationship"
        @selected="setBiologicalAssociation"
      >
        <template #all>
          <tag-item
            v-for="item in allItems"
            :key="item.id"
            display="name"
            :item="item"
            @select="setBiologicalAssociation(item)"
          />
        </template>
      </smart-selector>
    </div>
  </fieldset>
</template>

<script>

import TagItem from '../shared/item_tag.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import refreshSmartSelector from '../shared/refreshSmartSelector'
import { BiologicalRelationship } from 'routes/endpoints'

export default {
  mixins: [refreshSmartSelector],
  components: {
    TagItem,
    SmartSelector
  },
  data () {
    return {
      view: undefined,
      allItems: {}
    }
  },
  mounted () {
    this.loadTabList()
  },
  methods: {
    loadTabList () {
      BiologicalRelationship.all().then(response => {
        this.allItems = response.body
      })
    },
    setBiologicalAssociation (item) {
      this.$emit('select', item)
    }
  }
}
</script>
