<template>
  <div class="data_attribute_annotator">
    <h3 v-if="!dataAttributes.length">
      <i
        >Set new default attributes using project preferences, or use the radial
        annotator.</i
      >
    </h3>
    <template v-else>
      <div class="field separate-bottom separate-top">
        <template
          v-for="(item, index) in dataAttributes"
          :key="item.controlled_vocabulary_term_id"
        >
          <div class="field label-above">
            <label>
              {{ defaultPredicates[index].name }}
            </label>
            <input
              class="full_width"
              v-model="item.value"
              type="text"
            />
          </div>
        </template>
      </div>

      <div>
        <button
          @click="createNew()"
          class="button button-submit normal-input separate-bottom"
          type="button"
        >
          Create
        </button>
      </div>
    </template>

    <TableList
      :list="list"
      :header="['Name', 'Value', '']"
      :attributes="['predicate_name', 'value']"
      target-citations="data_attributes"
      @edit="(item) => (dataAttribute = item)"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import {
  DataAttribute,
  ControlledVocabularyTerm,
  Project
} from '@/routes/endpoints'
import TableList from '@/components/radials/annotator/components/shared/tableList.vue'
import { PREDICATE } from '@/constants'
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

const customPredicate = ref([])
const predicates = ref([])
const dataAttributes = ref([])
const list = ref([])

const defaultPredicates = computed(() =>
  predicates.value.filter((item) => customPredicate.value.includes(item.id))
)

loadTabList()

function makeDataAttribute() {
  return {
    type: 'InternalAttribute',
    controlled_vocabulary_term_id: undefined,
    value: '',
    attribute_subject_id: props.objectId,
    attribute_subject_type: props.objectType
  }
}

function createNew() {
  const data = dataAttributes.value.filter((item) => item.value.trim().length)
  const promises = data.map((item) =>
    DataAttribute.create({ data_attribute: item })
  )

  Promise.all(promises).then((responses) => {
    list.value.push(...responses.map((r) => r.body))
    emit('update-count', list.value.length)
    createFields()
  })
}

async function loadTabList() {
  customPredicate.value =
    (await Project.preferences()).body.model_predicate_sets[props.objectType] ||
    []
  predicates.value = (
    await ControlledVocabularyTerm.all({ type: [PREDICATE] })
  ).body

  createFields()
}

function createFields() {
  dataAttributes.value = defaultPredicates.value.map((item) => ({
    ...makeDataAttribute(),
    controlled_vocabulary_term_id: item.id
  }))
}

function removeItem(item) {
  DataAttribute.destroy(item.id)

  removeFromArray(list.value, item)
  emit('update-count', list.value.length)
}

DataAttribute.where({
  attribute_subject_id: props.objectId,
  attribute_subject_type: props.objectType
}).then(({ body }) => {
  list.value = body
})
</script>
