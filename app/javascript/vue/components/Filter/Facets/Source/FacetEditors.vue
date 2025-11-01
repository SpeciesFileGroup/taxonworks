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

const editors = ref([])

watch(
  () => props.modelValue.editor_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      editors.value = []
    }
  },
  { deep: true }
)
watch(
  editors,
  (newVal) => {
    params.value.editor_id = newVal.map((editor) => editor.id)
  },
  { deep: true }
)

onBeforeMount(() => {
  if (params.value.editor_id) {
    params.value.editor_id.forEach((id) => {
      People.find(id).then((response) => {
        addEditor(response.body)
      })
    })
  }
})

function addEditor(editor) {
  if (!params.value.editor_id?.includes(editor.id)) {
    editors.value.push(editor)
  }
}

function removeEditor(index) {
  editors.value.splice(index, 1)
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}
</style>
