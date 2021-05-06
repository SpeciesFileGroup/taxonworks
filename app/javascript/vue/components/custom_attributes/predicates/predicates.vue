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
        href="/controlled_vocabulary_terms/new">Create a term (Predicate)
      </a>
    </fieldset>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import PredicateRow from './components/predicateRow'
import { GetPredicates, GetPredicatesCreated, GetProjectPreferences } from './request/resources.js'

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
  data() {
    return {
      loading: true,
      createdList: [],
      list: [],
      data_attributes: [],
      modelPreferencesIds: undefined,
      predicatesList: []
    }
  },
  watch: {
    objectId (newVal) {
      if (newVal && this.objectType) {
        this.loading = true
        GetPredicatesCreated(this.objectType, this.objectId).then(response => {
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
      if (this.modelPreferences?.length) {
        this.loadPredicates(this.modelPreferences)
      } else {
        GetProjectPreferences().then(response => {
          this.modelPreferencesIds = response.body.model_predicate_sets[this.model]
          this.loadPredicates(this.modelPreferencesIds)
        })
      }
    },
    loadPredicates (ids) {
      const promises = []
      if (ids.length) {
        promises.push(GetPredicates(ids).then(response => {
          this.predicatesList = response.body
        }))
      } else {
        this.predicatesList = []
      }

      if (this.objectId) {
        promises.push(GetPredicatesCreated(this.objectType, this.objectId).then(response => {
          this.createdList = response.body
        }))
      }

      Promise.all(promises).then(() => {
        this.loading = false
      })
    },
    findExisting (id) {
      return this.createdList.find(item => item.controlled_vocabulary_term_id === id)
    },
    addDataAttribute (dataAttribute) {
      const index = this.data_attributes.findIndex(item => item.controlled_vocabulary_term_id === dataAttribute.controlled_vocabulary_term_id)

      if (index > -1) {
        this.$set(this.data_attributes, index, dataAttribute)
      } else {
        this.data_attributes.push(dataAttribute)
      }

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