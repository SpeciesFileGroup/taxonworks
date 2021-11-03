<template>
  <block-layout
    anchor="classification"
    :warning="checkValidation"
    :spinner="!taxon.id">
    <template #header>
      <h3>Classification</h3>
    </template>
    <template #body>
      <div v-if="editMode">
        <p class="inline">
          <span class="separate-right">Editing relationship: </span>
          <span v-html="editMode.object_tag"/>
          <span
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="closeEdit"/>
        </p>
      </div>
      <div v-if="!taxonRelation">
        <div
          class="horizontal-left-content">
          <autocomplete
            url="/taxon_names/autocomplete"
            label="label_html"
            min="2"
            @getItem="taxonRelation = $event"
            event-send="autocompleteTaxonRelationshipSelected"
            placeholder="Search taxon name for the new classification..."
            :add-params="{ type: 'Protonym', 'nomenclature_group[]': ['Family', 'HigherClassification'] }"
            param="term"/>
          <button
            v-if="showParentButton"
            type="button"
            class="button normal-input button-default margin-small-left"
            @click="setInsertaeSedis">
            Set to parent
          </button>
        </div>
      </div>
      <template v-else>
        <div>
          <p class="inline">
            <span v-html="taxonLabel"/>
            <span
              type="button"
              title="Undo"
              class="circle-button button-default btn-undo"
              @click="taxonRelation = undefined"/>
          </p>
          <ul class="no_bullets">
            <li @click.prevent="addEntry(incertaeSedis[nomenclaturalCode])">
              <label>
                <input type="radio">
                Incertae sedis
              </label>
            </li>
            <li @click.prevent="addEntry(SourceClassifiedAs)">
              <label>
                <input type="radio">
                Source classified as
              </label>
            </li>
          </ul>
        </div>
      </template>
      <list-entrys
        @update="loadTaxonRelationships"
        @addCitation="setRelationship"
        @delete="removeRelationship"
        :edit="true"
        @edit="editRelationship"
        :list="GetRelationshipsCreated"
        :display="['subject_status_tag', { link: '/tasks/nomenclature/browse?taxon_name_id=', label: 'object_object_tag', param: 'object_taxon_name_id'}]"/>
    </template>
  </block-layout>
</template>
<script>

import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import BlockLayout from 'components/layout/BlockLayout'
import ListEntrys from './listEntrys.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'

export default {
  components: {
    ListEntrys,
    Autocomplete,
    BlockLayout
  },
  computed: {
    taxonLabel () {
      return this.taxonRelation.label_html || this.taxonRelation.object_tag
    },
    GetRelationshipsCreated () {
      return this.$store.getters[GetterNames.GetTaxonRelationshipList].filter(function (item) {
        return (item.type.endsWith('::UncertainPlacement') || item.type.endsWith('::SourceClassifiedAs'))
      })
    },
    showParentButton () {
      return Object.keys(this.incertaeSedis).includes(this.nomenclaturalCode)
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation].taxonRelationshipList.list
    },
    checkValidation () {
      return !!this.softValidation.filter(item => this.GetRelationshipsCreated.find(created => created.id === item.instance.id)).length
    },
    nomenclaturalCode () {
      return this.$store.getters[GetterNames.GetNomenclaturalCode]
    }
  },
  data () {
    return {
      taxonRelation: undefined,
      editMode: undefined,
      incertaeSedis: {
        iczn: 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement',
        icvcn: 'TaxonNameRelationship::Icvcn::Accepting::UncertainPlacement'
      },
      SourceClassifiedAs: 'TaxonNameRelationship::SourceClassifiedAs'
    }
  },
  methods: {
    setInsertaeSedis: function () {
      this.taxonRelation = this.parent
    },
    loadTaxonRelationships: function () {
      this.$store.dispatch(ActionNames.LoadTaxonRelationships, this.taxon.id)
    },
    removeRelationship: function (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonRelationship, item).then(() => {
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
      })
    },
    setRelationship (item) {
      this.$store.dispatch(ActionNames.UpdateTaxonRelationship, item)
    },
    addEntry: function (item) {
      if (this.editMode) {
        const relationship = {
          id: this.editMode.id,
          subject_taxon_name_id: this.taxon.id,
          object_taxon_name_id: this.taxonRelation.hasOwnProperty('object_taxon_name_id') ? this.taxonRelation.object_taxon_name_id : this.taxonRelation.id,
          type: item
        }

        this.$store.dispatch(ActionNames.UpdateTaxonRelationship, relationship).then(() => {
          this.taxonRelation = undefined
          this.editMode = undefined
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      } else {
        this.$store.dispatch(ActionNames.AddTaxonRelationship, {
          type: item,
          object_taxon_name_id: this.taxonRelation.id,
          subject_taxon_name_id: this.taxon.id
        }).then(() => {
          this.taxonRelation = undefined
          this.$store.commit(MutationNames.UpdateLastChange)
        }, (errors) => {})
      }
    },
    closeEdit () {
      this.editMode = undefined
      this.taxonRelation = undefined
    },
    editRelationship(value) {
      this.taxonRelation = value
      this.editMode = this.taxonRelation
    }
  }
}
</script>
