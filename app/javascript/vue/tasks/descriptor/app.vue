<template>
  <div id="new_descriptor_task">
    <spinner
      :full-screen="true"
      :legend="(loading ? 'Loading...' : 'Saving changes...')"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="loading || saving"
    />
    <div class="flex-separate middle">
      <h1>{{ (descriptor['id'] ? 'Edit' : 'New') }} descriptor</h1>
      <ul class="context-menu">
        <li>
          <div class="horizontal-left-content">
            <span>Add to matrix:</span>
            <div
              class="horizontal-left-content"
              v-if="matrix">
              <a
                class="margin-small-left"
                :href="`/tasks/observation_matrices/new_matrix/${matrix.id}`"
                v-html="matrix.object_tag"/>
              <span
                class="button circle-button btn-undo button-default"
                @click="unsetMatrix"/>
            </div>
            <div
              class="horizontal-left-content"
              v-else>
              <autocomplete
                class="margin-small-left"
                url="/observation_matrices/autocomplete"
                param="term"
                label="label"
                placeholder="Search a observation matrix..."
                @getItem="loadMatrix($event.id)"
              />
              <default-pin
                section="ObservationMatrices"
                type="ObservationMatrix"
                @getId="loadMatrix"/>
            </div>
          </div>
        </li>
        <li>
          <a href="/tasks/observation_matrices/observation_matrix_hub/index">Observation matrix hub</a>
        </li>
        <li>
          <span
            @click="resetDescriptor"
            data-icon="reset"
            class="middle reload-app"
          >Reset</span>
        </li>
      </ul>
    </div>
    <div>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <type-component
            class="separate-bottom"
            :descriptor-id="descriptor['id']"
            v-model="descriptor.type"
          />
          <template v-if="descriptor.type">
            <definition-component
              class="separate-bottom"
              :descriptor="descriptor"
              @save="saveDescriptor(descriptor)"
              @onNameChange="descriptor.name = $event"
              @onShortNameChange="descriptor.short_name = $event"
              @onKeyNameChange="descriptor.key_name = $event"
              @onDescriptionNameChange="descriptor.description_name = $event"
              @onDescriptionChange="descriptor.description = $event"
            />
            <template v-if="existComponent">
              <div>
                <spinner
                  legend="Create a definition"
                  :show-spinner="false"
                  :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}"
                  v-if="!descriptor['id']"
                />
                <component
                  v-if="descriptor.type && showDescriptor"
                  :is="loadComponent + 'Component'"
                  @save="saveDescriptor"
                  :descriptor="descriptor"
                />
              </div>
            </template>
          </template>
        </div>
        <div
          id="cright-panel"
          v-if="descriptor['id']"
        >
          <preview-component
            class="separate-left"
            :descriptor="descriptor"
            @remove="removeDescriptor"
          />
        </div>
      </div>
    </div>
  </div>
</template>
<script>

import Spinner from 'components/spinner.vue'
import Autocomplete from 'components/autocomplete.vue'
import TypeComponent from './components/type/type.vue'
import DefinitionComponent from './components/definition/definition.vue'
import QualitativeComponent from './components/character/character.vue'
import ContinuousComponent from './components/units/units.vue'
import PreviewComponent from './components/preview/preview.vue'
import GeneComponent from './components/gene/gene.vue'
import { CreateDescriptor, UpdateDescriptor, DeleteDescriptor, LoadDescriptor, CreateObservationMatrixColumn, GetMatrix } from './request/resources'
import setParam from 'helpers/setParam'
import DefaultPin from 'components/getDefaultPin'

export default {
  components: {
    QualitativeComponent,
    TypeComponent,
    DefinitionComponent,
    ContinuousComponent,
    PreviewComponent,
    GeneComponent,
    Spinner,
    Autocomplete,
    DefaultPin
  },
  computed: {
    loadComponent () {
      return this.descriptor.type ? this.descriptor.type.split('::')[1] : undefined
    },
    showDescriptor () {
      return !['Sample', 'PresenceAbsence'].includes(this.loadComponent)
    },
    existComponent () {
      return this.$options.components[this.loadComponent + 'Component']
    }
  },
  data () {
    return {
      matrix: undefined,
      descriptor: {
        type: undefined,
        name: undefined,
        description: undefined,
        description_name: undefined,
        key_name: undefined,
        short_name: undefined
      },
      loading: false,
      saving: false
    }
  },
  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const matrixId = urlParams.get('observation_matrix_id')

    if (matrixId) {
      this.loadMatrix(matrixId)
    }

    const descriptorId = location.pathname.split('/')[4]
    if (/^\d+$/.test(descriptorId)) {
      this.loading = true
      LoadDescriptor(descriptorId).then(response => {
        this.descriptor = response
        this.loading = false
      })
    }
  },
  methods: {
    resetDescriptor () {
      this.descriptor = {
        type: undefined,
        name: undefined,
        description: undefined
      }
    },
    saveDescriptor (descriptor) {
      this.saving = true
      if (this.descriptor.hasOwnProperty('id')) {
        UpdateDescriptor(descriptor).then(response => {
          this.descriptor = response
          this.saving = false
          TW.workbench.alert.create('Descriptor was successfully updated.', 'notice')
        }, rejected => {
          this.saving = false
        })
      } else {
        CreateDescriptor(descriptor).then(response => {
          this.descriptor = response
          this.saving = false
          history.pushState(null, null, `/tasks/descriptors/new_descriptor/${response.id}`)
          TW.workbench.alert.create('Descriptor was successfully created.', 'notice')
          if (this.matrix) {
            this.addToMatrix(this.descriptor)
          }
        }, rejected => {
          this.saving = false
        })
      }
    },
    removeDescriptor (descriptor) {
      DeleteDescriptor(descriptor.id).then(response => {
        this.resetDescriptor()
        history.pushState(null, null, '/tasks/descriptors/new_descriptor/')
        TW.workbench.alert.create('Descriptor was successfully deleted.', 'notice')
      })
    },
    addToMatrix (descriptor) {
      const data = {
        descriptor_id: descriptor.id,
        observation_matrix_id: this.matrix.id,
        type: 'ObservationMatrixColumnItem::SingleDescriptor'
      }
      CreateObservationMatrixColumn(data).then(() => {
        TW.workbench.alert.create('Descriptor was successfully added to the matrix.', 'notice')
      })
    },
    loadMatrix (id) {
      GetMatrix(id).then(response => {
        this.matrix = response
        setParam('/tasks/descriptors/new_descriptor', 'observation_matrix_id', this.matrix.id)
      })
    },
    unsetMatrix () {
      this.matrix = undefined
      setParam('/tasks/descriptors/new_descriptor', 'observation_matrix_id', this.matrix)
    }
  }
}
</script>
<style lang="scss">
  #new_descriptor_task {
    flex-direction: column-reverse;
    margin: 0 auto;
    margin-top: 1em;
    max-width: 1240px;

    input[type="text"], textarea {
      width: 300px;
    }

    .cleft, .cright {
      min-width: 350px;
      max-width: 350px;
      width: 300px;
    }
    #cright-panel {
      width: 350px;
      max-width: 350px;
    }
    .cright-fixed-top {
      top:68px;
      width: 1240px;
      z-index:200;
      position: fixed;
    }
    .anchor {
       display:block;
       height:65px;
       margin-top:-65px;
       visibility:hidden;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }

    .reload-app {
      cursor: pointer;
      &:hover {
        opacity: 0.8;
      }
    }
  }
</style>
