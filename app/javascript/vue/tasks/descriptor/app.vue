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
            <span>Matrix:</span>
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
          <a :href="observationMatrixHubPath">Observation matrix hub</a>
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
            <div class="panel basic-information">
              <div class="header">
                <h3>{{ sectionName }}</h3>
              </div>
              <div class="body">
                <definition-component
                  class="separate-bottom"
                  v-model="descriptor"
                  @save="saveDescriptor(descriptor)"
                />
                <template v-if="existComponent">
                  <div>
                    <component
                      v-if="descriptor.type"
                      :is="loadComponent + 'Component'"
                      @save="saveDescriptor($event, false)"
                      v-model="descriptor"
                    />
                  </div>
                </template>
                <create-component
                  v-if="!hideSaveButton"
                  :descriptor="descriptor"
                  @save="saveDescriptor(descriptor)"
                />
              </div>
            </div>
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
import Autocomplete from 'components/ui/Autocomplete.vue'
import TypeComponent from './components/type/type.vue'
import DefinitionComponent from './components/definition/definition.vue'
import QualitativeComponent from './components/character/character.vue'
import UnitComponent from './components/units/units.vue'
import PreviewComponent from './components/preview/preview.vue'
import GeneComponent from './components/gene/gene.vue'
import setParam from 'helpers/setParam'
import DefaultPin from 'components/getDefaultPin'
import CreateComponent from './components/save/save.vue'
import { RouteNames } from 'routes/routes'
import {
  Descriptor,
  ObservationMatrix,
  ObservationMatrixColumnItem
} from 'routes/endpoints'

import TYPES from './const/types'

export default {
  components: {
    QualitativeComponent,
    TypeComponent,
    DefinitionComponent,
    ContinuousComponent: UnitComponent,
    SampleComponent: UnitComponent,
    PreviewComponent,
    GeneComponent,
    Spinner,
    Autocomplete,
    DefaultPin,
    CreateComponent,
  },

  computed: {
    loadComponent () {
      return this.descriptor.type ? this.descriptor.type.split('::')[1] : undefined
    },
    existComponent () {
      return this.$options.components[this.loadComponent + 'Component']
    },
    matrixId () {
      return this.matrix ? this.matrix.id : undefined
    },
    sectionName () {
      return TYPES()[this.descriptor.type]
    },
    hideSaveButton () {
      return this.hideSaveButtonFor.includes(this.descriptor.type)
    },
    observationMatrixHubPath () {
      return RouteNames.ObservationMatricesHub
    }
  },

  data () {
    return {
      matrix: undefined,
      descriptor: this.newDescriptor(),
      loading: false,
      saving: false,
      hideSaveButtonFor: ['Descriptor::Gene']
    }
  },

  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const matrixId = urlParams.get('observation_matrix_id')
    const descriptorId = urlParams.get('descriptor_id') || location.pathname.split('/')[4]

    if (/^\d+$/.test(matrixId)) {
      this.loadMatrix(matrixId)
    }

    if (/^\d+$/.test(descriptorId)) {
      this.loadDescriptor(descriptorId)
    }
  },

  methods: {
    resetDescriptor () {
      this.descriptor = this.newDescriptor()
      this.setParameters()
    },

    newDescriptor () {
      return {
        id: undefined,
        type: undefined,
        name: undefined,
        description: undefined,
        description_name: undefined,
        key_name: undefined,
        short_name: undefined,
        weight: undefined
      }
    },

    saveDescriptor (descriptor, redirect = true) {
      this.saving = true
      if (descriptor.id) {
        Descriptor.update(descriptor.id, { descriptor }).then(response => {
          this.descriptor = response.body
          this.saving = false
          TW.workbench.alert.create('Descriptor was successfully updated.', 'notice')
          if (this.matrix && redirect) {
            window.open(`/tasks/observation_matrices/new_matrix/${this.matrixId}`, '_self')
          }
        }, rejected => {
          this.saving = false
        })
      } else {
        Descriptor.create({ descriptor }).then(response => {
          this.descriptor = response.body
          this.saving = false
          this.setParameters()
          TW.workbench.alert.create('Descriptor was successfully created.', 'notice')
          if (this.matrix) {
            this.addToMatrix(this.descriptor, redirect)
          }
        }, rejected => {
          this.saving = false
        })
      }
    },

    removeDescriptor (descriptor) {
      Descriptor.destroy(descriptor.id).then(() => {
        this.resetDescriptor()
        this.setParameters()
        TW.workbench.alert.create('Descriptor was successfully deleted.', 'notice')
      })
    },

    addToMatrix (descriptor, redirect) {
      const data = {
        descriptor_id: descriptor.id,
        observation_matrix_id: this.matrix.id,
        type: 'ObservationMatrixColumnItem::Single::Descriptor'
      }
      ObservationMatrixColumnItem.create({ observation_matrix_column_item: data }).then(() => {
        TW.workbench.alert.create('Descriptor was successfully added to the matrix.', 'notice')
        if (redirect) {
          window.open(`/tasks/observation_matrices/new_matrix/${this.matrixId}`, '_self')
        }
      })
    },

    loadDescriptor (descriptorId) {
      this.loading = true
      Descriptor.find(descriptorId).then(response => {
        this.descriptor = response.body
      }).finally(() => {
        this.loading = false
        this.setParameters()
      })
    },

    loadMatrix (id) {
      ObservationMatrix.find(id).then(response => {
        this.matrix = response.body
        this.setParameters()
      })
    },

    unsetMatrix () {
      this.matrix = undefined
      this.setParameters()
    },

    setParameters () {
      setParam('/tasks/descriptors/new_descriptor', { descriptor_id: this.descriptor.id, observation_matrix_id: this.matrixId })
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
