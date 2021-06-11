<template>
  <div>
    <h2>Attributes (predicates) to include</h2>
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.id"
      >
        <label>
          <checkbox-component
            :val="item.id"
            v-model="selected"
            @change="updateList"
          />
          <span v-html="item.object_tag" />
        </label>
      </li>
    </ul>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true">New predicate
    </button>
    <predicate-modal
      v-if="showModal"
      @close="showModal = false"
      @onNew="newPredicate" />
  </div>
</template>

<script>

import PredicateModal from './newPredicate'
import CheckboxComponent from './checkboxComponent'

import { ControlledVocabularyTerm } from 'routes/endpoints'

export default {
  components: {
    PredicateModal,
    CheckboxComponent
  },

  props: {
    modelList: {
      type: Array,
      default: () => []
    }
  },

  emits: ['onUpdate'],

  data () {
    return {
      list: [],
      selected: [],
      showModal: false
    }
  },

  watch: {
    modelList (newVal) {
      this.selected = newVal
    }
  },

  created () {
    ControlledVocabularyTerm.where({ type: ['Predicate'] }).then(response => {
      this.list = response.body
    })
  },

  methods: {
    newPredicate (predicate) {
      ControlledVocabularyTerm.create({ controlled_vocabulary_term: predicate }).then(response => {
        TW.workbench.alert.create('Predicate was successfully created.', 'notice')
        this.list.push(response.body)
      })
    },

    updateList () {
      this.$emit('onUpdate', this.selected)
    }
  }
}
</script>
