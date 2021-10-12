<template>
  <div class="tag_annotator">
    <div class="horizontal-right-content">
      <a :href="manageCVTLink()">New keyword</a>
    </div>
    <smart-selector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{'type[]' : 'Keyword'}"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      buttons
      inline
      klass="Tag"
      :custom-list="{ all: allList }"
      @selected="createWithId"/>
    <display-list
      :label="['keyword', 'name']"
      :list="list"
      @delete="removeItem"
      class="list"/>
  </div>
</template>
<script>

import CRUD from '../request/crud.js'
import annotatorExtend from '../components/annotatorExtend.js'
import SmartSelector from 'components/ui/SmartSelector.vue'
import DisplayList from './displayList.vue'
import { ControlledVocabularyTerm, Tag } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'

export default {
  mixins: [CRUD, annotatorExtend],

  components: {
    DisplayList,
    SmartSelector
  },

  created () {
    ControlledVocabularyTerm.where({ type: ['Keyword'] }).then(({ body }) => {
      this.allList = body
    })
  },

  data () {
    return {
      allList: []
    }
  },

  methods: {
    createWithId ({ id }) {
      const tag = {
        keyword_id: id,
        annotated_global_entity: decodeURIComponent(this.globalId)
      }

      Tag.create({ tag }).then(response => {
        this.list.push(response.body)
        TW.workbench.alert.create('Tag was successfully created.', 'notice')
      })
    },

    manageCVTLink () {
      return RouteNames.ManageControlledVocabularyTask
    }
  }
}
</script>
