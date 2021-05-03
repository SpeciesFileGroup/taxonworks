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

import { Project } from 'routes/endpoints'

export default {
  components: {
    ModelComponent,
    PredicatesComponent
  },

  computed: {
    modelList () {
      return this.preferences?.model_predicate_sets?.[this.model] || []
    }
  },

  data () {
    return {
      model: undefined,
      preferences: {}
    }
  },

  created () {
    Project.preferences().then(response => {
      this.preferences = response.body
    })
  },

  methods: {
    setModel (model) {
      this.model = model.value
    },

    updatePredicatePreferences (newPreferences) {
      if (!this.model) return
      const data = this.preferences.model_predicate_sets

      data[this.model] = newPreferences
      Project.update(this.preferences.id, { project: { model_predicate_sets: data } }).then(({ body }) => {
        this.preferences = body.preferences
        this.preferences.id = body.id
      })
    }
  }
}
</script>