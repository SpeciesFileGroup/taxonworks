<template>
  <div class="data_attribute_annotator">
    <SmartSelector
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      :klass="objectType"
      :custom-list="{ all }"
      :lock-view="false"
      :filter-ids="list.map((item) => item.controlled_vocabulary_term_id)"
      @selected="
        ($event) => {
          predicate = $event
        }
      "
      v-model="predicate"
    />
    <hr v-if="predicate" />
    <SmartSelectorItem
      :item="predicate"
      @unset="() => (predicate = undefined)"
    />

    <textarea
      v-model="text"
      class="separate-bottom"
      placeholder="Value"
    />

    <div class="horizontal-left-content gap-small margin-small-bottom">
      <VBtn
        medium
        color="create"
        :disabled="!validateFields"
        @click="saveDataAttribute()"
      >
        {{ selectedDataAttribute.id ? 'Update' : 'Create' }}
      </VBtn>
      <VBtn
        medium
        color="primary"
        @click="resetForm"
      >
        New
      </VBtn>
    </div>
    <TableList
      :list="internalAttributes"
      :header="['Name', 'Value', '']"
      :attributes="['predicate_name', 'value']"
      edit
      target-citations="data_attributes"
      @edit="setDataAttribute"
      @delete="removeItem"
    />

    <div
      v-if="importList.length"
      class="margin-medium-top"
    >
      <h3>Import attributes</h3>
      <TableList
        :list="importList"
        :header="['Name', 'Value', '']"
        :attributes="['import_predicate', 'value']"
        :destroy="false"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { ControlledVocabularyTerm, DataAttribute } from '@/routes/endpoints'
import { IMPORT_ATTRIBUTE, PREDICATE } from '@/constants'
import { useSlice } from '@/components/radials/composables'
import VBtn from '@/components/ui/VBtn/index.vue'
import TableList from './shared/tableList'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  globalId: {
    type: String,
    required: true
  },

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

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const all = ref([])
const predicate = ref()
const selectedDataAttribute = ref({})
const text = ref()

const validateFields = computed(() => predicate.value && text.value.length)
const importList = computed(() =>
  list.value.filter((item) => item.base_class === IMPORT_ATTRIBUTE)
)
const internalAttributes = computed(() =>
  list.value.filter((item) => item.base_class !== IMPORT_ATTRIBUTE)
)

function resetForm() {
  predicate.value = undefined
  text.value = ''
  selectedDataAttribute.value = {}
}

function saveDataAttribute() {
  const currentId = selectedDataAttribute.value.id
  const payload = {
    data_attribute: {
      id: currentId,
      type: 'InternalAttribute',
      value: text.value,
      controlled_vocabulary_term_id: predicate.value.id,
      annotated_global_entity: decodeURIComponent(props.globalId)
    }
  }

  const request = currentId
    ? DataAttribute.update(currentId, payload)
    : DataAttribute.create(payload)

  request.then(({ body }) => {
    addToList(body)
    resetForm()
  })
}

function removeItem(item) {
  DataAttribute.destroy(item).then((_) => {
    removeFromList(item)
  })
}

function setDataAttribute(dataAttribute) {
  selectedDataAttribute.value = dataAttribute
  predicate.value = dataAttribute.controlled_vocabulary_term
  text.value = dataAttribute.value
}

ControlledVocabularyTerm.where({ type: [PREDICATE] }).then((response) => {
  all.value = response.body
})

DataAttribute.where({
  attribute_subject_id: props.objectId,
  attribute_subject_type: props.objectType
}).then(({ body }) => {
  list.value = body
})
</script>
<style lang="scss">
.radial-annotator {
  .data_attribute_annotator {
    textarea {
      padding-top: 14px;
      padding-bottom: 14px;
      width: 100%;
      min-height: 100px;
    }

    .vue-autocomplete-input {
      width: 100%;
    }
  }
}
</style>
