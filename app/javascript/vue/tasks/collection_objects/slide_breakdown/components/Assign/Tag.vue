<template>
  <fieldset>
    <legend>Tag</legend>
    <div class="align-start">
      <smart-selector
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{'type[]' : 'Keyword'}"
        get-url="/controlled_vocabulary_terms/"
        model="keywords"
        klass="CollectionObject"
        pin-section="Keywords"
        pin-type="Keyword"
        @selected="addTag"/>
      <lock-component
        class="margin-small-left"
        v-model="lock.tags_attributes"/>
    </div>
    <list-component
      v-if="collectionObject.tags_attributes.length"
      :list="collectionObject.tags_attributes"
      @delete="removeTag"
      label="object_tag"/>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import ListComponent from 'components/displayList'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],
  components: {
    SmartSelector,
    ListComponent
  },
  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject)
      }
    }
  },
  methods: {
    addTag (tag) {
      if(this.collectionObject.tags_attributes.find(item => { return tag.id === item.keyword_id })) return
      this.collectionObject.tags_attributes.push({ keyword_id: tag.id, object_tag: tag.object_tag })
    },
    removeTag (tag) {
      let index = this.collectionObject.tags_attributes.findIndex(item => { return item.keyword_id === tag.keyword_id })
      this.collectionObject.tags_attributes.splice(index, 1)
    }
  }
}
</script>
