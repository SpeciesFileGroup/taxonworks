<template>
  <div class="tag_annotator">
    <div class="horizontal-right-content">
      <a
        target="_blank"
        :href="RouteNames.ManageControlledVocabularyTask"
      >
        New keyword
      </a>
    </div>
    <smart-selector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': KEYWORD }"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      buttons
      inline
      klass="Tag"
      :target="objectType"
      :custom-list="{ all: allList }"
      @selected="createWithId"
    />
    <display-list
      :label="['keyword', 'name']"
      :list="list"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import { ControlledVocabularyTerm, Tag } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { KEYWORD } from '@/constants'
import { ref } from 'vue'
import { removeFromArray } from '@/helpers'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update-count'])

const allList = ref([])
const list = ref([])

ControlledVocabularyTerm.where({ type: [KEYWORD] }).then(({ body }) => {
  allList.value = body
})

function createWithId({ id }) {
  const tag = {
    keyword_id: id,
    tag_object_id: props.objectId,
    tag_object_type: props.objectType
  }

  Tag.create({ tag }).then((response) => {
    list.value.push(response.body)
    emit('update-count', list.value.length)
    TW.workbench.alert.create('Tag was successfully created.', 'notice')
  })
}

function removeItem(item) {
  Tag.destroy(item.id).then((_) => {
    removeFromArray(list.value, item)
    emit('update-count', list.value.length)
  })
}

Tag.where({
  tag_object_id: props.objectId,
  tag_object_type: props.objectType,
  per: 500
}).then(({ body }) => {
  list.value = body
})
</script>
