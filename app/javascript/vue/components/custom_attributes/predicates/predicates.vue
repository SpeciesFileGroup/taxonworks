<template>
  <div class="custom_attributes">
    <fieldset>
      <spinner-component
        v-if="loading"
      />
      <legend>Custom attributes</legend>
      <template
        v-if="predicatesList.length">
        <predicate-row
          v-for="item in predicatesList"
          :key="item.id"
          :object-id="objectId"
          :object-type="objectType"
          :predicate-object="item"
          :existing="findExisting(item.id)"
          @onUpdate="addDataAttribute"
        />
      </template>
      <a
        v-else
        href="/tasks/projects/preferences/index">Select visible predicates
      </a>
    </fieldset>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import PredicateRow from './components/predicateRow'
import {
  Project,
  ControlledVocabularyTerm,
  DataAttribute
} from 'routes/endpoints'
import { addToArray } from 'helpers/arrays'

export default {
  components: {
    PredicateRow,
    SpinnerComponent
  },
  props: {
    model: {
      type: String,
      required: true
    },

    objectId: {
      required: true
    },

    objectType: {
      type: String,
      required: true
    },

    modelPreferences: {
      type: Array,
      required: false
    }
  },

  emits: ['onUpdate'],

  data () {
    return {
      loading: true,
      createdList: [],
      list: [],
      data_attributes: [],
      modelPreferencesIds: undefined,
      predicatesList: [],
      sortedIds: []
    }
  },

  watch: {
    objectId (newVal) {
      if (newVal && this.objectType) {
        this.loading = true
        DataAttribute.where({
          attribute_subject_type: this.objectType,
          attribute_subject_id: this.objectId,
          type: 'InternalAttribute'
        }).then(response => {
          this.createdList = response.body
          this.loading = false
        })
      } else {
        this.createdList = []
      }
    }
  },

  created () {
    this.loadPreferences()
  },

  methods: {
    loadPreferences () {
      Project.preferences().then(response => {
        this.modelPreferencesIds = response.body.model_predicate_sets[this.model]
        this.sortedIds = response.body.model_predicate_sets?.predicate_index || []
        this.loadPredicates(this.modelPreferencesIds)
      })
    },

    async loadPredicates (ids) {
      this.predicatesList = ids?.length
        ? (await ControlledVocabularyTerm.where({ type: ['Predicate'], id: ids })).body
        : []

      this.predicatesList.sort((a, b) => this.sortedIds.indexOf(a.id) - this.sortedIds.indexOf(b.id))

      if (this.objectId) {
        await DataAttribute.where({
          attribute_subject_type: this.objectType,
          attribute_subject_id: this.objectId,
          type: 'InternalAttribute'
        }).then(response => {
          this.createdList = response.body
        })
      }

      this.loading = false
    },

    findExisting (id) {
      return this.createdList.find(item => item.controlled_vocabulary_term_id === id)
    },

    addDataAttribute (dataAttribute) {
      addToArray(this.data_attributes, dataAttribute, 'controlled_vocabulary_term_id')
      this.$emit('onUpdate', this.data_attributes)
    }
  }
}
</script>

<style lang="scss">
  .custom_attributes {
    input {
      width: 100%;
    }
    .vue-autocomplete-input {
      width: 100% !important;
    }
  }
</style>
