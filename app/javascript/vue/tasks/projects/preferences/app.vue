<template>
  <div>
    <VSpinner v-if="isLoading" />
    <h1>Project - Customize attributes.</h1>
    <a
      class="cursor-pointer"
      @click="goBack"
    >
      Back
    </a>
    <div class="horizontal-left-content align-start">
      <VModel
        class="separate-right"
        v-model="model"
      />
      <div class="flex-direction-column">
        <VPredicates
          class="margin-medium-left margin-medium-bottom"
          :model-list="modelList"
          :list="predicates"
          :model="model"
          @update="updatePredicatePreferences"
        />
        <predicate-form @create="addToArray(predicates, $event)" />
      </div>
    </div>
  </div>
</template>

<script setup>
import PredicateForm from './components/newPredicate'
import VModel from './components/model'
import VPredicates from './components/predicates'
import VSpinner from '@/components/ui/VSpinner.vue'
import { ControlledVocabularyTerm, Project } from '@/routes/endpoints'
import { addToArray } from '@/helpers/arrays'
import { computed, ref } from 'vue'

const modelList = computed(
  () => preferences.value?.model_predicate_sets?.[model.value] || []
)
const model = ref(undefined)
const preferences = ref({})
const predicates = ref([])
const isLoading = ref(true)

const updatePredicatePreferences = (newPreferences) => {
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

function goBack() {
  history.back()
}

Project.preferences().then(({ body }) => {
  preferences.value = body

  ControlledVocabularyTerm.where({ type: ['Predicate'] })
    .then(({ body }) => {
      const sortedIds =
        preferences.value.model_predicate_sets.predicate_index || []

      predicates.value = sortedIds
        ? body.sort((a, b) => sortedIds.indexOf(a.id) - sortedIds.indexOf(b.id))
        : body
    })
    .finally(() => {
      isLoading.value = false
    })
})
</script>
