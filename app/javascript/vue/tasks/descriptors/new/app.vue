<template>
  <div id="new_descriptor_task">
    <spinner
      :full-screen="true"
      :legend="(loading ? 'Loading...' : 'Saving changes...')"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="loading || saving"
    />
    <div class="flex-separate middle">
      <h1>{{ (descriptor.id ? 'Edit' : 'New') }} descriptor</h1>
      <ul class="context-menu">
        <li>
          <a :href="observationMatrixHubPath">Observation matrix hub</a>
        </li>
        <li>
          <span
            @click="resetDescriptor"
            data-icon="reset"
            class="middle cursor-pointer"
          >Reset</span>
        </li>
      </ul>
    </div>
    <div>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <type-component
            :descriptor-id="descriptor.id"
            v-model="descriptor.type"
          />
          <block-layout
            v-if="descriptor.type"
            class="margin-medium-top">
            <template #header>
              <h3>{{ sectionName }}</h3>
            </template>
            <template #body>
              <definition-component
                class="separate-bottom"
                v-model="descriptor"
                @save="saveDescriptor(descriptor)"
              />

              <div v-if="existComponent">
                <component
                  v-if="descriptor.type"
                  :is="loadComponent + 'Component'"
                  @save="saveDescriptor($event, false)"
                  v-model="descriptor"
                />
              </div>
              <template v-if="!hideSaveButton">
                <v-btn
                  color="create"
                  medium
                  :disabled="!descriptor.name"
                  @click="saveDescriptor(descriptor, false)"
                >
                  {{
                    descriptor.id
                      ? 'Update'
                      : 'Create'
                  }}
                </v-btn>
                <v-btn
                  v-if="matrix"
                  class="margin-small-left"
                  color="create"
                  medium
                  :disabled="!descriptor.name"
                  @click="saveDescriptor(descriptor)"
                >
                  {{
                    descriptor.id
                      ? 'Update and return to matrix'
                      : 'Create and return to matrix'
                  }}
                </v-btn>

                <v-btn
                  class="margin-small-left"
                  color="create"
                  medium
                  :disabled="!descriptor.name"
                  @click="saveDescriptor(descriptor, false).then(_ => { resetDescriptor() })"
                >
                  {{
                    descriptor.id
                      ? 'Update and new'
                      : 'Create and new'
                  }}
                </v-btn>
              </template>
            </template>
          </block-layout>
          <matrix-component
            class="margin-medium-top"
            v-model="matrix" />
        </div>
        <div
          id="cright-panel"
          v-if="descriptor.id"
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
import VBtn from 'components/ui/VBtn/index.vue'
import makeDescriptor from 'factory/Descriptor.js'
import MatrixComponent from './components/matrix/Matrix.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import { RouteNames } from 'routes/routes'
import {
  Descriptor,
  ObservationMatrixColumnItem
} from 'routes/endpoints'
import {
  DESCRIPTOR_GENE,
  OBSERVATION_MATRIX_COLUMN_SINGLE_DESCRIPTOR
} from 'constants/index.js'
import DESCRIPTOR_TYPE from './const/types'

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
    VBtn,
    BlockLayout,
    MatrixComponent
  },

  computed: {
    loadComponent () {
      return this.descriptor.type ? this.descriptor.type.split('::')[1] : undefined
    },

    existComponent () {
      return this.$options.components[this.loadComponent + 'Component']
    },

    matrixId () {
      return this.matrix?.id
    },

    sectionName () {
      return DESCRIPTOR_TYPE[this.descriptor.type]
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
      descriptor: makeDescriptor(),
      loading: false,
      saving: false,
      hideSaveButtonFor: [DESCRIPTOR_GENE]
    }
  },

  watch: {
    matrix: {
      handler () {
        this.setParameters()
      },
      deep: true
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const descriptorId = urlParams.get('descriptor_id') || location.pathname.split('/')[4]

    if (/^\d+$/.test(descriptorId)) {
      this.loadDescriptor(descriptorId)
    }
  },

  methods: {
    resetDescriptor () {
      this.descriptor = makeDescriptor()
      this.setParameters()
    },

    saveDescriptor (descriptor, redirect = true) {
      const isUpdate = !!descriptor.id
      const saveRecord = isUpdate
        ? Descriptor.update(descriptor.id, { descriptor })
        : Descriptor.create({ descriptor })

      this.saving = true

      return saveRecord.then(async response => {
        this.descriptor = response.body

        if (this.matrix) {
          if (!isUpdate) {
            this.setParameters()
            await this.addToMatrix(this.descriptor, redirect)
          }
          if (redirect) {
            window.open(`/tasks/observation_matrices/new_matrix/${this.matrixId}`, '_self')
          }
        }

        TW.workbench.alert.create(`Descriptor was successfully ${isUpdate ? 'updated' : 'created'}.`, 'notice')
      }).finally(_ => {
        this.saving = false
      })
    },

    removeDescriptor (descriptor) {
      Descriptor.destroy(descriptor.id).then(() => {
        this.resetDescriptor()
        this.setParameters()
        TW.workbench.alert.create('Descriptor was successfully deleted.', 'notice')
      })
    },

    async addToMatrix (descriptor) {
      const data = {
        descriptor_id: descriptor.id,
        observation_matrix_id: this.matrix.id,
        type: OBSERVATION_MATRIX_COLUMN_SINGLE_DESCRIPTOR
      }

      return ObservationMatrixColumnItem.create({ observation_matrix_column_item: data }).then(() => {
        TW.workbench.alert.create('Descriptor was successfully added to the matrix.', 'notice')
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
  }
</style>
