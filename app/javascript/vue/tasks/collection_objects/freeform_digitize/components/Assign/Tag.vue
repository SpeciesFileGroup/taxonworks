<template>
  <fieldset>
    <legend>Tag</legend>
    <div class="align-start">
      <smart-selector
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{ 'type[]': 'Keyword' }"
        get-url="/controlled_vocabulary_terms/"
        model="keywords"
        klass="CollectionObject"
        target="CollectionObject"
        pin-section="Keywords"
        pin-type="Keyword"
        @selected="addTag"
      />
      <lock-component
        class="margin-small-left"
        v-model="lock.tags_attributes"
      />
    </div>
    <list-component
      v-if="store.tags.length"
      :list="store.tags"
      @delete="removeTag"
      label="object_tag"
    />
  </fieldset>
</template>

<script setup>
import useLockStore from '../../store/lock.js'
import useStore from '../../store/store.js'
import SmartSelector from '@/components/ui/SmartSelector'
import ListComponent from '@/components/displayList'

const lock = useLockStore()
const store = useStore()

function addTag(tag) {
  if (!store.tags.find((item) => tag.id === item.keyword_id)) {
    store.tags.push({
      keyword_id: tag.id,
      object_tag: tag.object_tag
    })
  }
}
function removeTag(tag) {
  store.tags = store.tags.filter((item) => item.keyword_id === tag.keyword_id)
}
</script>
