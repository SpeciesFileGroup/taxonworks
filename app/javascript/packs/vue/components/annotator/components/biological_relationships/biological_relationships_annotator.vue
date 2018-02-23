<template>
  <div class="biological_relationships_annotator">
    <div class="separate-bottom">
      <template>
        <h3 v-if="biologicalRelationship">
          {{ biologicalRelationship.name }}
          <span
            @click="biologicalRelationship = undefined"
            class="separate-left"
            data-icon="reset"/>
        </h3>
        <h3 v-else>Choose relationship</h3>
      </template>

      <template>
        <h3 v-if="biologicalRelation">
          <span v-html="biologicalRelation.object_tag"/>
          <span
            @click="biologicalRelation = undefined"
            class="separate-left"
            data-icon="reset"/>
        </h3>
        <h3 v-else>
          <span>Choose relation</span>
        </h3>
      </template>
    </div>

    <biological
      v-if="!biologicalRelationship"
      @select="biologicalRelationship = $event"/>
    <related
      v-if="!biologicalRelation"
      @select="biologicalRelation = $event"/>
    <new-citation
      @create="citation = $event"
      :global-id="globalId"/>

    <div>
      <button
        type="button"
        :disabled="!validateFields"
        @click="createAssociation"
        class="normal-input button button-submit">Create
      </button>
    </div>
    <table-list 
      class="separate-top"
      :header="['Relationship', 'type', 'object tag', 'Citation', '']"
      :attributes="[['biological_relationship', 'name'], 'biological_association_object_type', 'object_tag', ['source','object_tag']]"
      :list="list"
      @delete="removeItem"/>
  </div>
</template>
<script>

  import CRUD from '../../request/crud.js'
  import AnnotatorExtend from '../annotatorExtend.js'
  import Biological from './biological.vue'
  import Related from './related.vue'
  import NewCitation from './newCitation.vue'
  import TableList from '../../../table_list.vue'

  export default {
    mixins: [CRUD, AnnotatorExtend],
    components: {
      Biological,
      Related,
      NewCitation,
      TableList
    },
    computed: {
      validateFields() {
        return this.biologicalRelationship && this.biologicalRelation
      }
    },
    data() {
      return {
        list: [],
        biologicalRelationship: undefined,
        biologicalRelation: undefined,
        citation: undefined
      }
    },
    methods: {
      createAssociation() {
        let data = {
          biological_relationship_id: this.biologicalRelationship.id,
          biological_association_object_id: this.biologicalRelation.id,
          biological_association_object_type: this.biologicalRelation.type,
          subject_global_id: this.globalId,
          origin_citation_attributes: this.citation
        }

        this.create('/biological_associations.json', { biological_association: data }).then(response => {
          this.list.push(response.body)
        })
      },
      resetForm() {

      }
    },
  }
</script>
<style type="text/css" lang="scss">
  .radial-annotator {
    .biological_relationships_annotator {
      overflow-y: scroll;
      button {
        min-width: 100px;
      }
      .switch-radio {
        label {
          min-width: 95px;
        }
      }
      textarea {
        padding-top: 14px;
        padding-bottom: 14px;
        width: 100%;
        height: 100px;
      }
      .pages {
        width: 86px;
      }
      .vue-autocomplete-input, .vue-autocomplete {
        width: 376px;
      }
    }
  }
</style>
