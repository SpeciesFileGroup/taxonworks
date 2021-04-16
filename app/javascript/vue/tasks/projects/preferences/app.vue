<template>
  <div>
    <h1>Project - Customize attributes.</h1>
    <a
      v-if="Object.keys(preferences)"
      :href="`/projects/${preferences.id}`">Back</a>
    <div class="horizontal-left-content align-start">
      <model-component
        class="separate-right"
        @onSelect="setModel"
      />
      <predicates-component
        :model-list="modelList"
        @onUpdate="updatePredicatePreferences"
        class="separate-left"
      />
    </div>
  </div>
</template>

<script>

import ModelComponent from './components/model'
import PredicatesComponent from './components/predicates'

import { GetProjectPreferences, UpdateProjectPreferences } from './request/resources.js'

export default {
  components: {
    ModelComponent,
    PredicatesComponent
  },
  computed: {
    modelList () {
      if (!this.model) return []
      return this.preferences?.model_predicate_sets?.[this.model] || []
    }
  },
  data () {
    return {
      model: undefined,
      preferences: {}
    }
  },
  mounted () {
    GetProjectPreferences().then(response => {
      this.preferences = response.body
    })
  },
  methods: {
    setModel(model) {
      this.model = model.value
    },
    updatePredicatePreferences(newPreferences) {
      if (!this.model) return
      const data = this.preferences.model_predicate_sets
      data[this.model] = newPreferences

      UpdateProjectPreferences(this.preferences.id, { model_predicate_sets: data }).then(response => {
        this.preferences = response.body.preferences
        this.preferences.id = response.body.id
      })
    }
  }
}
</script>