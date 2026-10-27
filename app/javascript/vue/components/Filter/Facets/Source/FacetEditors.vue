<template>
  <FacetContainer>
    <h3>Editors</h3>
    <div class="field label-above">
      <label>Editor as text string</label>
      <input
        type="text"
        class="full_width"
        v-model="params.editor"
      />
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="params.exact_editor"
        />
        Exact
      </label>
    </div>
    <fieldset>
      <legend>Editor as role</legend>
      <smart-selector
        model="people"
        target="Editor"
        :autocomplete-params="{
          role_type: ['SourceEditor'],
          in_project: false
        }"
        label="cached"
        @selected="addEditor"
      />
      <label>
        <input
          v-model="params.editor_id_or"
          type="checkbox"
        />
        Any
      </label>
    </fieldset>
    <display-list
      :list="editors"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete-index="removeEditor"
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
  list: editors,
  hydrate,
  add: addEditor,
  remove: removeEditor
} = useHydratedFacetList({
  ids: () => params.value.editor_id,
  write: (items) => {
    params.value.editor_id = items.map((item) => item.id)
  },
  load: (id) => People.find(id).then(({ body }) => body),
  missing: missingRecord
})

onBeforeMount(() => {
  hydrate(params.value.editor_id)
})
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
