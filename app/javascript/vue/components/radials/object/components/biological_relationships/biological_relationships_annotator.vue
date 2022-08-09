<template>
  <div class="biological_relationships_annotator">
    <template v-if="createdBiologicalAssociation">
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

    <form-citation 
      v-model="citation"
      @lock="lockSource = $event"
    />
    <display-list
      v-if="createdBiologicalAssociation"
      edit
      class="margin-medium-top"
      label="citation_source_body"
      :list="createdBiologicalAssociation.citations"
      @edit="setCitation"
      @delete="removeCitation"
    />
    <div>
      <h3 v-html="metadata.object_tag" />
      <h3
        v-if="biologicalRelationship"
        class="relationship-title middle"
      >
        <span
          v-html="flip
            ? biologicalRelationship.inverted_name
            : biologicalRelationLabel"
        />

        <v-btn
          v-if="biologicalRelationship.inverted_name"
          color="primary"
          @click="flip = !flip"
        >
          Flip
        </v-btn>

        <v-btn
          class="margin-small-left margin-small-right"
          color="primary"
          circle
          @click="unsetBiologicalRelationship"
        >
          <v-icon
            name="undo"
            small
          />
        </v-btn>
        <lock-component v-model="lockRelationship" />
      </h3>
      <h3
        class="subtle relationship-title"
        v-else
      >
        Choose relationship
      </h3>

      <h3
        v-if="biologicalRelation"
        class="relation-title middle">
        <span v-html="displayRelated"/>
        <v-btn
          class="margin-small-left"
          color="primary"
          circle
          @click="biologicalRelation = undefined"
        >
          <v-icon
            name="undo"
            small
          />
        </v-btn>
      </h3>
      <h3
        v-else
        class="subtle relation-title">
        Choose related OTU/collection object
      </h3>
    </div>  
    <biological
      v-if="!biologicalRelationship"
      class="separate-bottom"
      @select="setBiologicalRelationship"
    />
    <related
      v-if="!biologicalRelation"
      class="separate-bottom separate-top"
      @select="biologicalRelation = $event"
    />

    <div class="separate-top">
      <button
        type="button"
        :disabled="!validateFields"
        @click="saveAssociation()"
        class="normal-input button button-submit"
      >
        {{ 
          createdBiologicalAssociation
            ? 'Update'
            : 'Create'
        }}
      </button>
    </div>

    <table-list
      class="separate-top"
      :list="list"
      :metadata="metadata"
      @edit="editBiologicalRelationship"
      @delete="removeItem"
    />
  </div>
</template>
<script>

import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../annotatorExtend.js'
import Biological from './biological.vue'
import Related from './related.vue'
import TableList from './table.vue'
import LockComponent from 'components/ui/VLock/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import FormCitation from '../asserted_distributions/sourcePicker.vue'
import makeEmptyCitation from '../../helpers/makeEmptyCitation.js'
import displayList from 'components/displayList.vue'
import { convertType } from 'helpers/types'
import { addToArray } from 'helpers/arrays.js'
import {
  BiologicalAssociation,
  BiologicalRelationship
} from 'routes/endpoints'

const EXTEND_PARAMS = [
  'origin_citation',
  'object',
  'subject',
  'biological_relationship',
  'citations',
  'source'
]

export default {
  mixins: [CRUD, AnnotatorExtend],

  components: {
    Biological,
    LockComponent,
    Related,
    TableList,
    VBtn,
    VIcon,
    FormCitation,
    displayList
  },

  computed: {
    validateFields () {
      return this.biologicalRelationship && this.biologicalRelation
    },

    displayRelated () {
      return this.biologicalRelation?.object_tag || this.biologicalRelation?.label_html
    },

    createdBiologicalAssociation () {
      return this.list.find(item =>
        item.biological_relationship_id === this.biologicalRelationship?.id &&
        item.biological_association_object_id === this.biologicalRelation?.id)
    },

    biologicalRelationLabel () {
      return this.biologicalRelationship?.label || this.biologicalRelationship?.name
    }
  },

  data () {
    return {
      list: [],
      biologicalRelationship: undefined,
      biologicalRelation: undefined,
      citation: makeEmptyCitation(),
      flip: false,
      lockSource: false,
      lockRelationship: false,
      loadOnMounted: false
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
        BiologicalRelationship.find(relationshipId).then(response => {
          this.biologicalRelationship = response.body
        })
      }
    }

    BiologicalAssociation.where({
      subject_global_id: this.globalId,
      extend: EXTEND_PARAMS
    }).then(({ body }) => {
      this.list = body
    })
  },

  methods: {
    reset () {
      if (!this.lockRelationship) {
        this.biologicalRelationship = undefined
      }
      this.biologicalRelation = undefined
      this.flip = false
      this.citation = {
        ...makeEmptyCitation(),
        source_id: this.lockSource ? this.citation.source_id : undefined,
        pages: this.lockSource ? this.citation.pages : undefined
      }
    },

    saveAssociation () {
      const data = {
        biological_relationship_id: this.biologicalRelationship.id,
        object_global_id: this.flip ? this.globalId : this.biologicalRelation.global_id,
        subject_global_id: this.flip ? this.biologicalRelation.global_id : this.globalId,
        citations_attributes: this.citation ? [this.citation] : undefined
      }
      const saveRequest = this.createdBiologicalAssociation
        ? BiologicalAssociation.update(this.createdBiologicalAssociation.id, { biological_association: data, extend: EXTEND_PARAMS })
        : BiologicalAssociation.create({ biological_association: data, extend: EXTEND_PARAMS })

      saveRequest.then(({ body }) => {
        addToArray(this.list, body)
        this.reset()
        TW.workbench.alert.create('Biological association was successfully saved.', 'notice')
      })
    },

    setCitation (citation) {
      this.citation = {
        id: citation.id,
        pages: citation.pages,
        source_id: citation.source_id,
        is_original: citation.is_original
      }
      this.editCitation = citation
    },

    removeCitation (item) {
      const biological_association = {
        citations_attributes: [{
          id: item.id,
          _destroy: true
        }]
      }

      BiologicalAssociation.update(
        this.createdBiologicalAssociation.id, {
          biological_association,
          extend: EXTEND_PARAMS
        })
        .then(({ body }) => {
          addToArray(this.list, body)
        })
    },

    editBiologicalRelationship (bioRelation) {
      this.biologicalRelationship = {
        id: bioRelation.biological_relationship_id,
        ...bioRelation.biological_relationship
      }

      this.biologicalRelation = {
        id: bioRelation.biological_association_object_id,
        ...bioRelation.object
      }
      this.flip = bioRelation.object.id === this.metadata.object_id
    },

    setBiologicalRelationship (item) {
      this.biologicalRelationship = item
      sessionStorage.setItem('radialObject::biologicalRelationship::id', item.id)
    },

    unsetBiologicalRelationship () {
      this.biologicalRelationship = undefined
      this.flip = false
    }
  }
}
</script>
<style lang="scss">
  .radial-annotator {
    .biological_relationships_annotator {
      .flip-button {
        min-width: 30px;
      }
      .relationship-title {
        margin-left: 1em
      }
      .relation-title {
        margin-left: 2em
      }

      .background-info {
        padding: 3px;
        padding-left: 6px;
        padding-right: 6px;
        border-radius: 3px;
        background-color: #DED2F9;
      }
    }
  }
</style>
