<template>
  <div>
    <h1>Project - Customize attributes.</h1>
    <a
      v-if="Object.keys(preferences)"
      :href="`/projects/${preferences.id}`"
    >
      Back
    </a>
    <div class="horizontal-left-content align-start">
      <model-component
        class="separate-right"
        v-model="model"
      />
      <predicates-component
        :model-list="modelList"
        :list="predicates"
        :model="model"
        @update="updatePredicatePreferences"
        class="separate-left"
      />
      <predicate-form @create="addToArray(predicates, $event)" />
    </div>
  </div>
</template>

<script setup>
import PredicateForm from './components/newPredicate'
import ModelComponent from './components/model'
import PredicatesComponent from './components/predicates'
import { ControlledVocabularyTerm, Project } from 'routes/endpoints'
import { addToArray } from 'helpers/arrays'
import { computed, ref } from 'vue'

const modelList = computed(() => preferences.value?.model_predicate_sets?.[model.value] || [])
const model = ref(undefined)
const preferences = ref({})
const predicates = ref([])

const updatePredicatePreferences = newPreferences => {
  if (!model.value) return

  const project = {
    model_predicate_sets: {
      ...preferences.value.model_predicate_sets,
      ...newPreferences
    }
  }

  Project.update(preferences.value.id, { project }).then(({ body }) => {
    preferences.value = {
      ...body.preferences,
      id: body.id
    }
  })
}

Project.preferences().then(({ body }) => {
  preferences.value = body

  ControlledVocabularyTerm.where({ type: ['Predicate'] }).then(({ body }) => {
    const sortedIds = preferences.value.model_predicate_sets.predicate_index || []

    predicates.value = sortedIds
      ? body.sort((a, b) => sortedIds.indexOf(a.id) - sortedIds.indexOf(b.id))
      : body
  })
})
</script>
