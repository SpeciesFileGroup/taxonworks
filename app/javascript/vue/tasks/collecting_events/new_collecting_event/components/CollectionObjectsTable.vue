<template>
  <div>
    <div>
      <spinner-component
        v-if="isLoading"
        legend="Loading"
        spinner-position="left"
        :legend-style="{
          fontSize: '14px'
        }"
        :logo-size="{
          width: '14px',
          height: '14px',
          marginRight: '4px'
        }"
      />
      <button
        type="button"
        class="button normal-input button-default"
        :disabled="!ceId"
        @click="showModal = true">
        Add/Current ({{ list.length }})</button>
    </div>
    <modal-component
      v-if="showModal"
      @close="showModal = false"
      :containerStyle="{ 
        width: '1000px',
        height: '90vh',
        overflowX: 'scroll'
      }">
      <div slot="header">
        <h3>Create collection objects</h3>
      </div>
      <div
        slot="body"
        class="horizontal-left-content align-start">
        <spinner-component
          v-if="isLoading || isSaving"
          :legend="isSaving ? `Creating ${index} of ${count} collection object(s)...` : 'Loading...'"/>
        <div class="full_width margin-medium-right">
          <div class="flex-separate align-end">
            <div class="field label-above">
              <label>Number to create</label>
              <input
                min="1"
                type="number"
                max="100"
                v-model.number="count">
            </div>
            <div class="field">
              <button
                class="button normal-input button-submit"
                type="button"
                @click="noCreated = []; createCOs(0)">
                Create
              </button>
            </div>
          </div>
          <label-component v-model="labelType"/>
          <identifiers-component
            v-model="identifier"
            :count="count"/>
          <preparation-types
            class="margin-medium-bottom"
            v-model="preparationType"/>
          <repository-component v-model="repositoryId"/>
          <biocuration-component
            class="margin-medium-bottom"
            v-model="biocurations"/>
          <determiner-component v-model="determinations"/>
          <tag-component v-model="tagList"/>
        </div>
        <div
          class="full_width">
          <template v-if="noCreated.length">
            <h3>Creation errors ({{ noCreated.length }})</h3>
            <table
              class="full_width margin-medium-bottom">
              <thead>
                <tr>
                  <th>Identifier</th>
                  <th>Error</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(item, index) in noCreated"
                  :key="index"
                  class="contextMenuCells feedback feedback-warning">
                  <td>{{ item.namespace }} {{ item.identifier }}</td>
                  <td>{{ Object.keys(item.error).map(k => item.error[k]).join(', ') }}</td>
                </tr>
              </tbody>
            </table>
          </template>
          <span>{{ list.length }} object(s) are already associated with this collecting event</span>
          <h3>Existing</h3>
          <table class="full_width">
            <thead>
              <tr>
                <th>ID</th>
                <th>Identifier</th>
                <th>Determination</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(item, index) in list"
                :key="item.id"
                class="contextMenuCells"
                :class="{ 'even': (index % 2 == 0) }">
                <td>{{ item.id }}</td>
                <td v-html="item.catalogNumber"/>
                <td v-html="item.scientificName"/>
                <td>
                  <div
                    v-if="item.global_id"
                    class="horizontal-left-content">
                    <radial-annotator :global-id="item.global_id"/>
                    <radial-navigation :global-id="item.global_id"/>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </modal-component>
  </div>
</template>

<script>

import BiocurationComponent from './Biocuration'
import PreparationTypes from './PreparationTypes'
import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import IdentifiersComponent from './Identifiers'
import DeterminerComponent from './Determiner'
import RepositoryComponent from './Repository'
import LabelComponent from './Label'
import TagComponent from './Tags'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialNavigation from 'components/radials/navigation/radial'
import { RouteNames } from 'routes/routes'
import {
  BiocurationClassification,
  CollectionObject,
  TaxonDetermination
} from 'routes/endpoints'

export default {
  components: {
    BiocurationComponent,
    DeterminerComponent,
    IdentifiersComponent,
    LabelComponent,
    ModalComponent,
    SpinnerComponent,
    RadialAnnotator,
    RadialNavigation,
    PreparationTypes,
    RepositoryComponent,
    TagComponent
  },

  props: {
    ceId: {
      type: [Number, String],
      default: undefined
    }
  },

  data () {
    return {
      biocurations: [],
      showModal: false,
      list: [],
      index: 0,
      isLoading: false,
      count: 1,
      identifier: {
        start: undefined,
        namespace: undefined
      },
      determinations: [],
      isSaving: false,
      noCreated: [],
      preparationType: undefined,
      repositoryId: undefined,
      labelType: undefined,
      tagList: []
    }
  },

  watch: {
    ceId: {
      handler (newVal) {
        this.noCreated = []
        if (newVal) {
          this.loadTable()
        } else {
          this.list = []
        }
      }
    }
  },

  methods: {
    async createCOs (index = 0) {
      this.index = index + 1
      this.isSaving = true
      if (index < this.count) {
        const identifier = {
          identifier: this.identifier.start + index,
          namespace: this.identifier.namespace
        }

        const co = {
          total: 1,
          repository_id: this.repositoryId,
          preparation_type_id: this.preparationType,
          collecting_event_id: this.ceId,
          tags_attributes: this.tagList.map(tag => ({ keyword_id: tag.id })),
          identifiers_attributes: identifier.identifier && identifier.namespace.id
            ? [{
                identifier: identifier.identifier,
                namespace_id: identifier.namespace.id,
                type: 'Identifier::Local::CatalogNumber',
                labels_attributes: this.labelType
                  ? [{
                      text_method: 'build_cached',
                      type: this.labelType,
                      total: 1
                    }]
                  : undefined
              }]
            : undefined
        }
        const promises = []
        await CollectionObject({ collection_object: co }).then(response => {
          this.determinations.forEach(determination => {
            determination.biological_collection_object_id = response.body.id
            promises.push(TaxonDetermination.create({ taxon_determination: determination }))
          })
          this.biocurations.forEach(biocurationId => {
            promises.push(BiocurationClassification.create({
              biocuration_classification: {
                biocuration_class_id: biocurationId,
                biological_collection_object_id: response.body.id
              }
            }))
          })
          index++
          Promise.all(promises).then(() => {
            this.createCOs(index)
          })
        }, (error) => {
          this.noCreated.unshift({
            identifier: identifier.identifier,
            namespace: identifier.namespace.name,
            error: error.body
          })
          index++
          this.createCOs(index)
        })
      } else {
        this.isSaving = false
        this.loadTable()
      }
    },
    openComprehensive (id) {
      window.open(`${RouteNames.DigitizeTask}?collection_object_id=${id}`, '_self')
    },
    loadTable () {
      this.isLoading = true
      CollectionObject.where({ collecting_event_ids: [this.ceId] }).then(response => {
        this.list = response.body
        this.isLoading = false
      })
    }
  }
}
</script>
