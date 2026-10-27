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
          role_type: ['SourceAuthor', 'SourceEditor'],
          in_project: false
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
      label="cached"
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
import { People } from '@/routes/endpoints'
import { computed, onBeforeMount } from 'vue'
import { useHydratedFacetList, missingRecord } from '@/components/Filter/composables/useHydratedFacetList.js'

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

const {
  list: authors,
  hydrate,
  add: addAuthor,
  remove: removeAuthor
} = useHydratedFacetList({
  ids: () => params.value.author_id,
  write: (items) => {
    params.value.author_id = items.map((item) => item.id)
  },
  load: (id) => People.find(id).then(({ body }) => body),
  missing: missingRecord
})

onBeforeMount(() => {
  hydrate(params.value.author_id)
})
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
