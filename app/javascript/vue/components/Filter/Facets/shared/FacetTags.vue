<template>
  <FacetContainer>
    <h3>Tags</h3>
    <fieldset>
      <legend>Keywords</legend>
      <smart-selector
        ref="smartSelectorRef"
        autocomplete-url="/controlled_vocabulary_terms/autocomplete"
        :autocomplete-params="{ 'type[]': 'Keyword' }"
        get-url="/controlled_vocabulary_terms/"
        model="keywords"
        klass="Tags"
        pin-section="Keywords"
        pin-type="Keyword"
        :add-tabs="['all']"
        :target="target"
        @selected="addKeyword"
      >
        <template #all>
          <VModal @close="smartSelectorRef.setTab('quick')">
            <template #header>
              <h3>Tags - all</h3>
            </template>
            <template #body>
              <VBtn
                v-for="item in allFiltered"
                :key="item.id"
                class="margin-small-bottom margin-small-right"
                color="primary"
                pill
                @click="addKeyword(item)"
              >
                {{ item.name }}
              </VBtn>
            </template>
          </VModal>
        </template>
      </smart-selector>
    </fieldset>
    <table
      v-if="keywords.length"
      class="vue-table"
    >
      <thead>
        <tr>
          <th>Name</th>
          <th />
          <th />
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <template
          v-for="(item, index) in keywords"
          :key="index"
        >
          <row-item
            class="list-complete-item"
            :item="item"
            label="object_tag"
            :options="{
              AND: true,
              OR: false
            }"
            v-model="keywords[index].and"
            @remove="removeKeyword(index)"
          />
        </template>
      </transition-group>
    </table>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import RowItem from './RowItem'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { computed, ref, watch, onBeforeMount } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  },

  target: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])
const smartSelectorRef = ref(null)

const params = computed({
  get: () => props.modelValue,
  set(value) {
    emit('update:modelValue', value)
  }
})

const allFiltered = computed(() => {
  const keywordsId = keywords.value.map(({ id }) => id)

  return allTags.value.filter((item) => !keywordsId.includes(item.id))
})

const keywords = ref([])
const allTags = ref([])

watch(
  [() => props.modelValue.keyword_id_and, () => props.modelValue.keyword_id_or],
  () => {
    if (
      !props.modelValue.keyword_id_and?.length &&
      !props.modelValue.keyword_id_or?.length &&
      keywords.value.length
    ) {
      keywords.value = []
    }
  }
)
watch(
  keywords,
  () => {
    params.value = {
      keyword_id_and: keywords.value
        .filter((keyword) => keyword.and)
        .map((keyword) => keyword.id),
      keyword_id_or: keywords.value
        .filter((keyword) => !keyword.and)
        .map((keyword) => keyword.id)
    }
  },
  { deep: true }
)

onBeforeMount(() => {
  const { keyword_id_and = [], keyword_id_or = [] } = props.modelValue

  keyword_id_and.forEach((id) => {
    ControlledVocabularyTerm.find(id).then((response) => {
      addKeyword(response.body, true)
    })
  })

  keyword_id_or.forEach((id) => {
    ControlledVocabularyTerm.find(id).then((response) => {
      addKeyword(response.body, false)
    })
  })

  ControlledVocabularyTerm.where({ type: ['Keyword'] }).then(({ body }) => {
    allTags.value = body
  })
})

function addKeyword(keyword, and = true) {
  if (!keywords.value.find((item) => item.id === keyword.id)) {
    keywords.value.push({ ...keyword, and })
  }
}

function removeKeyword(index) {
  keywords.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
