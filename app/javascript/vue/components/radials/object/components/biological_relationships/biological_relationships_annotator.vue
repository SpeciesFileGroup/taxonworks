<template>
  <div class="biological_relationships_annotator">
    <div class="separate-bottom">
      <template>
        <template v-if="edit">
          <div class="flex-separate">
            <h3>Edit mode</h3>
            <button
              type="button"
              class="button button-default"
              @click="reset">
              Cancel
            </button>
          </div>
          <br>
        </template>
        <h3 v-html="metadata.object_tag"/>
        <h3 v-if="biologicalRelationship" class="relationship-title middle">
          <template v-if="flip">
            <span
              v-for="item in biologicalRelationship.object_biological_properties"
              :key="item.id"
              class="separate-right background-info"
              v-html="item.name"/>
            <span
              v-html="biologicalRelationship.inverted_name"/>
            <span 
              v-for="item in biologicalRelationship.subject_biological_properties"
              :key="item.id"
              class="separate-left background-info"
              v-html="item.name"/>
          </template>
          <template v-else>
            <span 
              v-for="item in biologicalRelationship.subject_biological_properties"
              :key="item.id"
              class="separate-right background-info"
              v-html="item.name"/>
            <span>{{ (biologicalRelationship.hasOwnProperty('label') ? biologicalRelationship.label : biologicalRelationship.name) }}</span>
            <span 
              v-for="item in biologicalRelationship.object_biological_properties"
              :key="item.id"
              class="separate-left background-info"
              v-html="item.name"/>
          </template>
          <button
            v-if="biologicalRelationship.inverted_name"
            class="separate-left button button-default flip-button"
            type="button"
            @click="flip = !flip">
            Flip
          </button>
          <span
            @click="biologicalRelationship = undefined; flip = false"
            class="margin-small-left button button-default circle-button btn-undo"/>
          <lock-component v-model="lockRelationship"/>
        </h3>
        <h3
          class="subtle relationship-title"
          v-else>Choose relationship</h3>
      </template>

      <template>
        <h3
          v-if="biologicalRelation"
          class="relation-title middle">
          <span v-html="displayRelated"/>
          <span
            @click="biologicalRelation = undefined"
            class="margin-small-left button button-default circle-button btn-undo"/>
        </h3>
        <h3
          v-else
          class="subtle relation-title">Choose related OTU/collection object</h3>
      </template>
    </div>

    <biological
      v-if="!biologicalRelationship"
      class="separate-bottom"
      @select="setBiologicalRelationship"/>
    <related
      v-if="!biologicalRelation"
      class="separate-bottom separate-top"
      @select="biologicalRelation = $event"/>
    <new-citation
      class="separate-top"
      ref="citation"
      @lock="lockSource = $event"
      @create="citation = $event"
      :global-id="globalId"/>

    <div class="separate-top">
      <button
        type="button"
        :disabled="!validateFields"
        @click="edit ? updateAssociation() : createAssociation()"
        class="normal-input button button-submit">{{ edit ? 'Update' : 'Create' }}
      </button>
    </div>
    <table-list 
      class="separate-top"
      :list="list"
      :metadata="metadata"
      @edit="editBiologicalRelationship"
      @delete="removeItem"/>
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../annotatorExtend.js'
import Biological from './biological.vue'
import Related from './related.vue'
import NewCitation from './newCitation.vue'
import TableList from './table.vue'
import LockComponent from 'components/ui/VLock/index.vue'
import { convertType } from 'helpers/types'

export default {
  mixins: [CRUD, AnnotatorExtend],
  components: {
    Biological,
    LockComponent,
    Related,
    NewCitation,
    TableList
  },
  computed: {
    validateFields () {
      return this.biologicalRelationship && this.biologicalRelation
    },
    displayRelated () {
      return this.biologicalRelation?.object_tag || this.biologicalRelation?.label_html
    },
    alreadyExist () {
      return this.list.find(item => item.biological_relationship_id === this.biologicalRelationship.id && item.biological_association_object_id === this.biologicalRelation.id)
    }
  },
  data () {
    return {
      list: [],
      edit: undefined,
      biologicalRelationship: undefined,
      biologicalRelation: undefined,
      citation: undefined,
      flip: false,
      lockSource: false,
      lockRelationship: false,
      urlList: `/biological_associations.json?subject_global_id=${encodeURIComponent(this.globalId)}`
    }
  },
  watch: {
    lockRelationship (newVal) {
      sessionStorage.setItem('radialObject::biologicalRelationship::lock', newVal)
    }
  },
  created () {
    const value = convertType(sessionStorage.getItem('radialObject::biologicalRelationship::lock'))
    if (value !== null) {
      this.lockRelationship = value === true
    }

    if (this.lockRelationship) {
      const relationshipId = convertType(sessionStorage.getItem('radialObject::biologicalRelationship::id'))

      if (relationshipId) {
        this.getList(`/biological_relationships/${relationshipId}.json`).then(response => {
          this.biologicalRelationship = response.body
        })
      }
    }
  },
  methods: {
    reset () {
      if (!this.lockRelationship) {
        this.biologicalRelationship = undefined
      }
      this.biologicalRelation = undefined
      this.flip = false
      this.edit = undefined
      if (!this.lockSource) {
        this.citation = undefined
        this.$refs.citation.cleanCitation()
      }
    },
    createAssociation () {
      const data = {
        biological_relationship_id: this.biologicalRelationship.id,
        object_global_id: (this.flip ? this.globalId : this.biologicalRelation.global_id),
        subject_global_id: (this.flip ? this.biologicalRelation.global_id : this.globalId),
        citations_attributes: [this.citation]
      }
      if (this.alreadyExist) {
        this.update(`/biological_associations/${this.alreadyExist.id}.json`, { biological_association: data }).then(response => {
          const index = this.list.findIndex(item => item.id === response.body.id)

          this.reset()
          TW.workbench.alert.create('Citation was successfully added to biological association.', 'notice')
          this.list[index] = response.body
        })
      } else {
        this.create('/biological_associations.json', { biological_association: data }).then(response => {
          this.reset()
          TW.workbench.alert.create('Biological association was successfully created.', 'notice')
          this.list.push(response.body)
        })
      }
    },
    updateAssociation () {
      const data = {
        id: this.edit.id,
        biological_relationship_id: this.biologicalRelationship.id,
        object_global_id: (this.flip ? this.globalId : this.biologicalRelation.global_id),
        subject_global_id: (this.flip ? this.biologicalRelation.global_id : this.globalId),
      }

      if (this.citation) {
        data.citations_attributes = [this.citation]
      }

      this.update(`/biological_associations/${data.id}.json`, { biological_association: data }).then(response => {
        const index = this.list.findIndex(item => item.id === response.body.id)

        this.reset()
        this.list[index] = response.body
        TW.workbench.alert.create('Biological association was successfully updated.', 'notice')
      })
    },
    editBiologicalRelationship (bioRelation) {
      this.edit = bioRelation
      this.biologicalRelationship = bioRelation.biological_relationship
      this.biologicalRelation = bioRelation.object
      this.flip = (bioRelation.object.id === this.metadata.object_id)
    },
    setBiologicalRelationship (item) {
      this.biologicalRelationship = item
      sessionStorage.setItem('radialObject::biologicalRelationship::id', item.id)
    }
  }
}
</script>
<style lang="scss">
  .radial-annotator {
    .biological_relationships_annotator {
      overflow-y: scroll;
      .flip-button {
        min-width: 30px;
      }
      .relationship-title {
        margin-left: 1em
      }
      .relation-title {
        margin-left: 2em
      }
      .switch-radio {
        label {
          min-width: 95px;
        }
      }
      .background-info {
        padding: 3px;
        padding-left: 6px;
        padding-right: 6px;
        border-radius: 3px;
        background-color: #DED2F9;
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
