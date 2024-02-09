<template>
  <div class="citation_annotator">
    <div
      v-if="citation?.id"
      class="flex-separate gap-small"
    >
      <h3>
        Edit:
        <span v-html="citation.object_tag" />
      </h3>
      <VBtn
        circle
        color="primary"
        @click="() => (citation = newCitation())"
      >
        <VIcon
          name="undo"
          small
        />
      </VBtn>
    </div>
    <h3 v-else>New citation</h3>
    <FormCitation
      v-model="citation"
      :klass="objectType"
      :submit-button="{
        label: 'Save',
        color: 'create'
      }"
      @submit="saveCitation(citation)"
    >
      <template #footer>
        <VBtn
          class="margin-small-left"
          color="primary"
          medium
          @click="() => (citation = newCitation())"
        >
          New
        </VBtn>
      </template>
    </FormCitation>
    <div v-if="!citation.id">
      <TableList
        :list="list"
        @edit="citation = $event"
        @delete="removeItem"
      />
    </div>
    <div v-else>
      <CitationTopicForm
        v-if="!DISABLED_FOR.includes(objectType)"
        :object-type="objectType"
        :global-id="globalId"
        :citation="citation"
        @create="saveCitation"
      />
      <table class="full_width">
        <thead>
          <tr>
            <th>Topic</th>
            <th>Pages</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in citation.citation_topics"
            :key="item.id"
          >
            <td v-html="item.topic.object_tag" />
            <td>
              <TopicPages
                v-model="citation.citation_topics[index]"
                :citation-id="citation.id"
                @update="saveCitation"
              />
            </td>
            <td>
              <div class="horizontal-right-content">
                <VBtn
                  circle
                  color="destroy"
                  @click="() => deleteTopic(item)"
                >
                  <VIcon
                    x-small
                    name="trash"
                  />
                </VBtn>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <HandleCitations
      v-if="isModalVisible"
      :citation="citation"
      :original-citation="originalCitation"
      @save="(item) => addToArray(list, item)"
      @create="setCitation"
      @close="isModalVisible = false"
    />
  </div>
</template>
<script setup>
import TableList from './table.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import CitationTopicForm from './CitationTopicForm.vue'
import TopicPages from './TopicPages.vue'
import HandleCitations from './handleOriginalModal'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import makeCitation from '@/factory/Citation'
import { Citation } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { computed, ref } from 'vue'

const EXTEND_PARAMS = ['source', 'citation_topics']
const DISABLED_FOR = ['Content']

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

const emit = defineEmits('update-count')

const list = ref([])
const citation = ref(newCitation())
const isModalVisible = ref(false)

const originalCitation = computed(() => list.value.find((c) => c.is_original))

function setCitation(citation) {
  citation.value = citation
}

function newCitation() {
  return {
    ...makeCitation(),
    citation_object_id: props.objectId,
    citation_object_type: props.objectType,
    citation_topics_attributes: []
  }
}

function deleteTopic(topic) {
  const payload = {
    citation: {
      id: citation.value.id,
      citation_topics_attributes: [
        {
          id: topic.id,
          _destroy: true
        }
      ]
    },
    extend: EXTEND_PARAMS
  }

  Citation.update(citation.value.id, payload)
    .then((_) => {
      const index = citation.value.citation_topics.findIndex(
        (element) => element.id === topic.id
      )

      citation.value.citation_topics.splice(index, 1)
    })
    .catch(() => {})
}

function saveCitation(item) {
  const payload = {
    citation: {
      ...item,
      citation_object_id: props.objectId,
      citation_object_type: props.objectType
    },
    extend: EXTEND_PARAMS
  }

  if (
    item.is_original &&
    originalCitation.value &&
    originalCitation.value.id !== item.id
  ) {
    isModalVisible.value = true

    return
  }

  const request = item.id
    ? Citation.update(item.id, payload)
    : Citation.create(payload)

  request
    .then(({ body }) => {
      addToArray(list.value, body)
      citation.value = body
      emit('update-count', list.value.length)
      TW.workbench.alert.create('Citation was successfully saved.', 'notice')
    })
    .catch(() => {})
}

function removeItem(item) {
  Citation.destroy(item.id).then((_) => {
    removeFromArray(list.value, item)
    emit('update-count', list.value.length)
  })
}

Citation.all({
  citation_object_id: props.objectId,
  citation_object_type: props.objectType,
  extend: EXTEND_PARAMS
}).then(({ body }) => {
  list.value = body
})
</script>
<style lang="scss">
.radial-annotator {
  .citation_annotator {
    overflow-y: scroll;

    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      height: 100px;
    }
    .pages {
      width: 86px;
    }
    .vue-autocomplete-input,
    .vue-autocomplete {
      width: 400px;
    }
  }
}
</style>
