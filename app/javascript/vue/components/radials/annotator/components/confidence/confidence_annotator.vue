<template>
  <div class="confidence_annotator">
    <smart-selector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'ConfidenceLevel'}"
      get-url="/controlled_vocabulary_terms/"
      model="confidence_levels"
      button-class="button-submit"
      buttons
      inline
      klass="Tag"
      :filter="confidenceAlreadyCreated"
      :target="objectType"
      :custom-list="{ all: allList, new: [] }"
      @selected="createConfidence({ confidence_level_id: $event.id })"
    >
      <template #new>
        <NewConfidence @submit="createConfidence" />
      </template>
    </smart-selector>

    <list-items
      :label="['confidence_level', 'object_tag']"
      :list="list"
      @delete="removeItem"
      target-citations="confidences"
      class="list"
    />
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import annotatorExtend from '../../components/annotatorExtend.js'
import ListItems from '../shared/listItems.vue'
import SmartSelector from 'components/ui/SmartSelector.vue'
import NewConfidence from './NewConfidence.vue'
import { ControlledVocabularyTerm, Confidence } from 'routes/endpoints'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    ListItems,
    SmartSelector,
    NewConfidence
  },

  data () {
    return {
      allList: []
    }
  },

  created () {
    ControlledVocabularyTerm.where({ type: ['ConfidenceLevel'] }).then(response => {
      this.allList = response.body
    })
  },

  methods: {
    createConfidence (payload) {
      Confidence.create({
        confidence: {
          ...payload,
          annotated_global_entity: decodeURIComponent(this.globalId)
        }
      }).then(response => {
        this.list.push(response.body)
      })
    },

    confidenceAlreadyCreated (confidence) {
      return !this.list.find(item => confidence.id === item.confidence_level_id)
    }
  }
}
</script>
<style lang="scss">
  .radial-annotator {
    .confidence_annotator {
      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
      .vue-autocomplete-input {
        width: 100%;
      }
    }
  }
</style>
