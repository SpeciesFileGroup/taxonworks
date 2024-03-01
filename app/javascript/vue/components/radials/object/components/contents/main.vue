<template>
  <div class="content_annotator">
    <h3
      v-if="content.id"
      v-html="content.object_tag"
    />
    <h3 v-else>New record</h3>
    <fieldset class="margin-medium-bottom">
      <legend>Topic</legend>
      <SmartSelector
        class="full_width margin-small-bottom"
        ref="smartSelector"
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{ 'type[]': 'Topic' }"
        get-url="/controlled_vocabulary_terms/"
        model="topics"
        target="Content"
        klass="Otu"
        :add-tabs="['all']"
        pin-section="Topic"
        buttons
        inline
        label="name"
        pin-type="BiologicalRelationship"
        :filter="(topic) => list.every((item) => item.topic.id !== topic.id)"
        @selected="setTopic"
      >
        <template #all>
          <a
            v-if="!allTopics.length"
            target="blank"
            href="/controlled_vocabulary_terms/new"
          >
            Create a topic first.
          </a>
          <TopicItem
            v-for="item in topicsAvailable"
            :key="item.id"
            :topic="item"
            @select="setTopic"
          />
        </template>
      </SmartSelector>
      <hr />
      <SmartSelectorItem
        :item="topic"
        label="name"
        @unset="() => (topic = null)"
      />
    </fieldset>
    <div>
      <VSpinner
        v-if="!topic"
        :show-spinner="false"
        legend="Select a topic first"
      />
      <MarkdownEditor
        v-model="content.text"
        :configs="config"
      />
    </div>
    <div
      class="margin-small-top margin-small-bottom horizontal-left-content gap-small"
    >
      <VBtn
        color="create"
        medium
        :disabled="!validate"
        @click="saveContent"
      >
        {{ content.id ? 'Update' : 'Create' }}
      </VBtn>
      <VBtn
        color="primary"
        medium
        @click="
          () => {
            setContent(makeContent())
          }
        "
      >
        New
      </VBtn>
    </div>
    <TableList
      :header="['Text', 'Topic', '']"
      :attributes="['text_for_list', ['topic', 'name']]"
      :list="shortList"
      edit
      class="list"
      @delete="removeItem"
      @edit="setContent"
    />
  </div>
</template>

<script setup>
import TopicItem from '../citations/topicItem.vue'
import TableList from '@/components/table_list.vue'
import MarkdownEditor from '@/components/markdown-editor.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { shorten } from '@/helpers/strings.js'
import { ControlledVocabularyTerm, Content } from '@/routes/endpoints'
import { computed, ref, onBeforeMount } from 'vue'
import { useSlice } from '@/components/radials/composables'
import { TOPIC } from '@/constants'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const extend = ['otu', 'topic']

const config = {
  status: false,
  spellChecker: false
}

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const content = ref(makeContent())
const topic = ref(null)
const allTopics = ref([])

const topicsAvailable = computed(() =>
  allTopics.value.filter(
    (topic) => !list.value.find((item) => item.topic_id === topic.id)
  )
)

const validate = computed(() => content.value.text.length > 1 && topic.value)
const shortList = computed(() =>
  list.value.map((content) => ({
    ...content,
    text_for_list: shorten(content.text, 150)
  }))
)

onBeforeMount(async () => {
  ControlledVocabularyTerm.where({ type: [TOPIC] }).then(({ body }) => {
    allTopics.value = body
  })

  Content.where({
    otu_id: props.objectId,
    extend
  }).then(({ body }) => {
    list.value = body
  })
})

function saveContent() {
  const { text, id } = content.value
  const payload = {
    content: {
      id,
      text,
      topic_id: topic.value.id,
      otu_id: props.objectId,
      type: props.objectType
    },
    extend
  }

  const saveRecord = id ? Content.update(id, payload) : Content.create(payload)

  saveRecord.then(({ body }) => {
    addToList(body)
    TW.workbench.alert.create('Content was successfully saved.', 'notice')
    content.value = makeContent()
  })
}

function makeContent() {
  return {
    text: ''
  }
}

function setTopic(item) {
  topic.value = item
}

function setContent(item) {
  content.value = item
  topic.value = item?.topic
}

function removeItem(item) {
  Content.destroy(item.id).then((_) => {
    removeFromList(item)

    if (item.id === content.value?.id) {
      setContent(makeContent())
    }
  })
}
</script>
