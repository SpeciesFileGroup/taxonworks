<template>
  <FacetContainer>
    <h3>Author(s)</h3>

    <smart-selector
      model="people"
      target="Author"
      :autocomplete-params="{
        roles: ['TaxonNameAuthor']
      }"
      label="cached"
      @selected="addAuthor"
    />
    <label>
      <input
        v-model="params.taxon_name_author_ids_or"
        type="checkbox"
      >
      Any
    </label>

    <display-list
      :list="authors"
      label="object_tag"
      :delete-warning="false"
      @delete-index="removeAuthor"
    />

    <div class="field label-above">
      <label class="capitalize">Author</label>
      <input
        class="full_width"
        v-model="params.author_exact"
        type="text"
      >
      <label>
        <input
          v-model="params.author_exact"
          type="checkbox"
        >
        Exact
      </label>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { People } from 'routes/endpoints'
import { computed, ref, watch, onBeforeMount } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const authors = ref([])

watch(
  () => props.modelValue?.taxon_name_author_ids,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      authors.value = []
    }
  },
  { deep: true }
)

watch(
  authors,
  () => {
    params.value.taxon_name_author_ids = authors.value.map(author => author.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)
  const authorIds = urlParams.taxon_name_author_ids || []

  params.value.taxon_name_author_ids_or = urlParams.taxon_name_author_ids_or
  params.value.author = urlParams.author
  params.value.author_exact = urlParams.author_exact

  authorIds.forEach(id => {
    People.find(id).then(response => {
      addAuthor(response.body)
    })
  })
})

const addAuthor = author => {
  if (!params.value.taxon_name_author_ids?.includes(author.id)) {
    authors.value.push(author)
  }
}

const removeAuthor = index => {
  authors.value.splice(index, 1)
}
</script>
