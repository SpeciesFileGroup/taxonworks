<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      :disabled="!ceId"
      @click="showModal = true">Collection object(s) ({{ list.length }})</button>
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
        <span>{{ list.length }} object(s) are already associated with this collecting event</span>
      </div>
      <div
        slot="body"
        class="horizontal-left-content align-start">
        <spinner-component v-if="isLoading"/>
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
                @click="createCOs(0)">
                Create
              </button>
            </div>
          </div>
          <identifiers-component
            v-model="identifier"
            :count="count"/>
          <determiner-component v-model="determinations"/>
        </div>
        <table class="full_width">
          <thead>
            <tr>
              <th>Result</th>
              <th>ID</th>
              <th>Identifier</th>
              <th>Determination</th>
              <th>Annotator</th>
              <th>Comprehensive</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in list"
              :key="item.id"
              class="contextMenuCells"
              :class="{ 'even': (index % 2 == 0) }"
              @click="sendCO(item)">
              <td class="capitalize">{{ item.id ? 'success' : 'failed' }}
              <td>{{ item.id }}</td>
              <td v-html="item.object_tag"/>
              <td/>
              <td>
                <radial-annotator
                  v-if="item.global_id"
                  :global-id="item.global_id"/>
              </td>
              <td>
                <button
                  v-if="item.id"
                  type="button"
                  class="button normal-input button-default"
                  @click="openComprehensive(item.id)">
                  Open
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import SpinnerComponent from 'components/spinner'
import IdentifiersComponent from './Identifiers'
import DeterminerComponent from './Determiner'
import RadialAnnotator from 'components/radials/annotator/annotator'
import { RouteNames } from 'routes/routes'

import {
  GetCollectionObjects,
  CreateCollectionObject,
  CreateTaxonDetermination
} from '../request/resources.js'

export default {
  components: {
    DeterminerComponent,
    IdentifiersComponent,
    ModalComponent,
    SpinnerComponent,
    RadialAnnotator
  },
  props: {
    ceId: {
      type: [Number, String],
      default: undefined
    }
  },
  data () {
    return {
      showModal: false,
      list: [],
      isLoading: false,
      count: 1,
      identifier: {
        start: undefined,
        namespace_id: undefined
      },
      determinations: [],
      isSaving: false,
    }
  },
  watch: {
    ceId: {
      handler (newVal) {
        if (newVal) {
          this.isLoading = true
          GetCollectionObjects({ collecting_event_ids: [this.ceId] }).then(response => {
            this.list = response.body
            this.isLoading = false
          })
        } else {
          this.list = []
        }
      }
    }
  },
  methods: {
    sendCO (item) {
      this.showModal = false
      this.$emit('selected', item)
    },
    createCOs (index = 0) {
      this.isSaving = true
      if (index < this.count) {
        const identifier = {
          identifier: this.identifier.start + index,
          namespace_id: this.identifier.namespace_id,
          type: 'Identifier::Local::CatalogNumber'
        }

        const co = {
          total: 1,
          collecting_event_id: this.ceId,
          identifiers_attributes: identifier.identifier && identifier.namespace_id ? [identifier] : undefined
        }

        CreateCollectionObject(co).then(response => {
          this.list.unshift(response.body)
          this.determinations.forEach(determination => {
            determination.biological_collection_object_id = response.body.id
            CreateTaxonDetermination(determination).then(r => {

            })
          })
        }, () => {
          this.list.unshift({
            id: undefined,
            object_tag: 'Not created',
            identifier: `${identifier.identifier}`
          })
        }).finally(() => {
          index++
          this.createCOs(index)
        })
      } else {
        this.isSaving = false
      }
    },
    openComprehensive (id) {
      window.open(`${RouteNames.DigitizeTask}?collection_object_id=${id}`, '_self')
    }
  }
}
</script>
