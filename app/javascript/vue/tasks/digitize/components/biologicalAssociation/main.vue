<template>
  <div>
    <block-layout :warning="!list.find(item => item['id'])">
      <template #header>
        <h3>Biological Associations</h3>
      </template>
      <template #body>
        <div class="separate-bottom">
          <template>
            <div class="flex-separate middle">
              <h3
                v-if="biologicalRelationship"
                class="relationship-title">
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
                  class="separate-left"
                  data-icon="reset"/>
              </h3>
              <h3
                class="subtle relationship-title"
                v-else>Choose relationship</h3>
              <lock-component v-model="settings.locked.biological_association.relationship"/>
            </div>
          </template>

          <template>
            <div class="flex-separate middle">
              <h3
                v-if="biologicalRelation"
                class="relation-title">
                <span v-html="displayRelated"/>
                <span
                  @click="biologicalRelation = undefined"
                  class="separate-left"
                  data-icon="reset"/>
              </h3>
              <h3
                v-else
                class="subtle relation-title">Choose relation</h3>
              <lock-component v-model="settings.locked.biological_association.related"/>
            </div>
          </template>
        </div>
        <div
          v-if="!biologicalRelationship"
          class="horizontal-left-content full_width">
          <biological
            class="separate-bottom"
            @select="biologicalRelationship = $event"/>
        </div>
        <div class="horizontal-left-content">
          <related
            v-if="!biologicalRelation"
            class="separate-bottom separate-top"
            @select="biologicalRelation = $event"/>
        </div>
        <new-citation
          class="separate-top"
          ref="citation"
          @create="citation = $event"
          :global-id="'globalId'"/>

        <div class="separate-top">
          <button
            type="button"
            :disabled="!validateFields"
            @click="addAssociation"
            class="normal-input button button-submit">Add
          </button>
        </div>
        <table-list 
          v-if="collectionObject.id"
          class="separate-top"
          :list="list"
          @delete="removeBiologicalRelationship"/>
        <table-list 
          v-else
          class="separate-top"
          @delete="removeFromQueue"
          :list="queueAssociations"/>
      </template>
    </block-layout>
  </div>
</template>
<script>

import Biological from './biological.vue'
import Related from './related.vue'
import NewCitation from './newCitation.vue'
import TableList from './table.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import LockComponent from 'components/ui/VLock/index.vue'

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations'
import { BiologicalAssociation } from 'routes/endpoints'

export default {
  components: {
    Biological,
    Related,
    NewCitation,
    BlockLayout,
    TableList,
    LockComponent
  },
  computed: {
    validateFields() {
      return this.biologicalRelationship && this.biologicalRelation
    },
    displayRelated() {
      return this.biologicalRelation
        ? (this.biologicalRelation?.object_tag || this.biologicalRelation.label_html)
        : undefined
    },
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set () {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data() {
    return {
      list: [],
      biologicalRelationship: undefined,
      biologicalRelation: undefined,
      citation: undefined,
      queueAssociations: [],
      flip: false,
    }
  },
  watch: {
    collectionObject (newVal) {
      if (newVal.id) {
        BiologicalAssociation.where({ subject_global_id: newVal.global_id }).then(response => {
          this.list = response.body
          this.processQueue()
        })
      }
      if (!this.settings.locked.biological_association.relationship)
        this.biologicalRelationship = undefined
      if (!this.settings.locked.biological_association.related) {
        this.biologicalRelation = undefined
      }
    },
  },
  methods: {
    addAssociation () {
      const data = {
        biologicalRelationship: this.biologicalRelationship,
        biologicalRelation: this.biologicalRelation,
        citation: this.citation
      }
      this.queueAssociations.push(data)
      this.biologicalRelationship = this.settings.locked.biological_association.relationship ? this.biologicalRelationship : undefined
      this.biologicalRelation = this.settings.locked.biological_association.related ? this.biologicalRelation : undefined
      this.citation = undefined
      this.$refs.citation.cleanCitation()
      this.processQueue()
    },
    createAssociationObject(data) {
      return {
        biological_relationship_id: data.biologicalRelationship.id,
        biological_association_object_id: data.biologicalRelation.id,
        biological_association_object_type: data.biologicalRelation.type,
        subject_global_id: this.collectionObject.global_id,
        origin_citation_attributes: data.citation
      }
    },
    processQueue() {
      if(!this.collectionObject.id) return
      this.queueAssociations.forEach(item => {
        BiologicalAssociation.create({ biological_association: this.createAssociationObject(item) }).then(response => {
          this.list.push(response.body)
        })
      })
      this.queueAssociations = []
    },
    removeBiologicalRelationship(biologicalRelationship) {
      BiologicalAssociation.destroy(biologicalRelationship.id).then(() => {
        this.list.splice(this.list.findIndex((item) => item.id === biologicalRelationship.id), 1)
      })
    },
    removeFromQueue (index) {
      this.queueAssociations.splice(index, 1)
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
