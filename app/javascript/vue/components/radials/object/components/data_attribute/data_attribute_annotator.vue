<template>
  <div class="data_attribute_annotator">
    <h3 v-if="!data_attributes.length">
      <i>Set new default attributes using project preferences, or use the radial annotator.</i>
    </h3> 
    <template v-else>
      <div class="field separate-bottom separate-top">
        <template v-for="(predicate, index) in data_attributes">
          <div class="field">
            <label>
              {{ defaultPredicates[index].name }}
            </label>
            <br>
            <input
              class="full_width"
              v-model="predicate.value"
              type="text">
          </div>
        </template>
      </div>

      <div>
        <button
          @click="createNew()"
          class="button button-submit normal-input separate-bottom"
          type="button">Create
        </button>
      </div>
    </template>

    <table-list
      :list="list"
      :header="['Name', 'Value', '']"
      :attributes="['predicate_name', 'value']"
      :edit="true"
      target-citations="data_attributes"
      @edit="data_attribute = $event"
      @delete="removeItem"/>
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../../components/annotatorExtend.js'
import TableList from '../shared/tableList'

export default {
  mixins: [CRUD, AnnotatorExtend],

  components: { TableList },

  computed: {
    defaultPredicates () {
      return this.predicates.filter(item => this.customPredicate.find(predicateId => predicateId === item.id))
    }
  },

  data () {
    return {
      preferences: undefined,
      customPredicate: [],
      predicates: [],
      data_attributes: []
    }
  },

  mounted () {
    this.loadTabList()
  },

  methods: {
    newData () {
      return {
        type: 'InternalAttribute',
        controlled_vocabulary_term_id: undefined,
        value: '',
        annotated_global_entity: decodeURIComponent(this.globalId)
      }
    },

    createNew () {
      const promises = []
      const data = this.data_attributes.filter(item => item.value.trim().length)

      data.forEach(item => {
        promises.push(this.create('/data_attributes', { data_attribute: item }).then(response => {
          this.list.push(response.body)
        }))
      })

      Promise.all(promises).then(() => {
        this.createFields()
      })
    },

    predicateAlreadyCreated (predicate) {
      return this.list.find(item => predicate.id ===item.controlled_vocabulary_term_id)
    },

    loadTabList () {
      const promises = []

      promises.push(this.getList('/controlled_vocabulary_terms.json?type[]=Predicate').then(response => {
        this.predicates = response.body
      }))

      promises.push(this.getList('/project_preferences.json').then(response => {
        this.customPredicate = response.body.model_predicate_sets[this.metadata.object_type]
      }))

      Promise.all(promises).then(() => {
        this.createFields()
      })
    },

    createFields () {
      this.data_attributes = []
      this.defaultPredicates.forEach(item => {
        const data = this.newData()
        data.controlled_vocabulary_term_id = item.id
        this.data_attributes.push(data)
      })
    }
  }
}
</script>
