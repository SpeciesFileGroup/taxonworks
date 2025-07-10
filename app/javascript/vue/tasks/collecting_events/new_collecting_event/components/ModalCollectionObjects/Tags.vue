<template>
  <div>
    <h3>Tags</h3>
    <fieldset>
      <legend>Keyword</legend>
      <SmartSelector
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{ 'type[]': KEYWORD }"
        get-url="/controlled_vocabulary_terms/"
        model="keywords"
        klass="Tag"
        :target="COLLECTION_OBJECT"
        @selected="addTag"
      />
      <DisplayList
        label="object_tag"
        soft-delete
        :list="list"
        :delete-warning="false"
        @delete-index="removeTag"
      />
    </fieldset>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import DisplayList from '@/components/displayList'
import { COLLECTION_OBJECT, KEYWORD } from '@/constants'

const list = defineModel({
  type: Array,
  required: true
})

function addTag(tag) {
  list.value.push(tag)
}

function removeTag(index) {
  list.value.splice(index, 1)
}
</script>
