<template>
  <FacetContainer>
    <h3>Authors</h3>
    <div class="field label-above">
      <label>Author as text string</label>
      <input
        type="text"
        class="full_width"
        v-model="params.author"
      />
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="params.exact_author"
        />
        Exact
      </label>
    </div>
    <fieldset>
      <legend>Author as role</legend>
      <smart-selector
        model="people"
        target="Author"
        :autocomplete-params="{
          roles: ['SourceAuthor', 'SourceEditor']
        }"
        label="cached"
        @selected="addAuthor"
      />
      <label>
        <input
          v-model="params.author_id_or"
          type="checkbox"
        />
        Any
      </label>
    </fieldset>
    <display-list
      :list="authors"
      label="object_tag"
      :delete-warning="false"
      @delete-index="removeAuthor"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
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
  set: (value) => emit('update:modelValue', value)
})

const authors = ref([])

watch(
  () => props.modelValue.author_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      authors.value = []
    }
  },
  { deep: true }
)
watch(
  authors,
  (newVal) => {
    params.value.author_id = newVal.map((author) => author.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  if (params.value.author_id) {
    params.value.author_id.forEach((id) => {
      People.find(id).then((response) => {
        addAuthor(response.body)
      })
    })
  }
})

function addAuthor(author) {
  if (!params.value.author_id?.includes(author.id)) {
    authors.value.push(author)
  }
}

function removeAuthor(index) {
  authors.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
