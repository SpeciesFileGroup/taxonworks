<template>
  <FacetContainer>
    <h3>Authors</h3>

    <div class="field label-above">
      <label>Author as text string</label>
      <input
        class="full_width"
        v-model="params.author"
        type="text"
      />
      <label>
        <input
          v-model="params.author_exact"
          type="checkbox"
        />
        Exact
      </label>
    </div>

    <fieldset>
      <legend>Author as role</legend>
      <SmartSelector
        model="people"
        target="Author"
        :autocomplete-params="{
          role_type: TAXON_NAME_AUTHOR_SELECTOR,
          in_project: true
        }"
        label="cached"
        @selected="addAuthor"
      />
      <label>
        <input
          v-model="params.taxon_name_author_id_or"
          type="checkbox"
        />
        Any
      </label>
    </fieldset>

    <display-list
      :list="authors"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete-index="removeAuthor"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import SmartSelector from '@/components/ui/SmartSelector'
import DisplayList from '@/components/displayList'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import { People } from '@/routes/endpoints'
import { computed, ref, watch, onBeforeMount } from 'vue'
import { TAXON_NAME_AUTHOR_SELECTOR } from '@/constants/index.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const authors = ref([])

watch(
  () => props.modelValue?.taxon_name_author_id,
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
    params.value.taxon_name_author_id = authors.value.map((author) => author.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)
  const authorIds = urlParams.taxon_name_author_id || []

  params.value.taxon_name_author_id_or = urlParams.taxon_name_author_id_or
  params.value.author = urlParams.author
  params.value.author_exact = urlParams.author_exact

  authorIds.forEach((id) => {
    People.find(id).then((response) => {
      addAuthor(response.body)
    })
  })
})

const addAuthor = (author) => {
  if (!params.value.taxon_name_author_id?.includes(author.id)) {
    authors.value.push(author)
  }
}

const removeAuthor = (index) => {
  authors.value.splice(index, 1)
}
</script>
