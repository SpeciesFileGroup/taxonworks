<template>
  <div id="new_descriptor_task">
    <spinner
      :full-screen="true"
      :legend="(loading ? 'Loading...' : 'Saving changes...')"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="loading || saving"/>
    <div class="flex-separate middle">
      <h1>{{ (descriptor['id'] ? 'Edit' : 'New') }} descriptor</h1>
      <span
        @click="resetDescriptor"
        data-icon="reset"
        class="middle reload-app">Reset</span>
    </div>
    <div>
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item separate-right">
          <type-component 
            class="separate-bottom"
            :descriptor-id="descriptor['id']"
            v-model="descriptor.type"/>
          <template v-if="descriptor.type">
            <definition-component 
              class="separate-bottom"
              :descriptor="descriptor"
              @save="saveDescriptor(descriptor)"
              @onNameChange="descriptor.name = $event"
              @onShortNameChange="descriptor.short_name = $event"
              @onKeyNameChange="descriptor.key_name = $event"
              @onDescriptionNameChange="descriptor.description_name = $event"
              @onDescriptionChange="descriptor.description = $event"/>
            <template v-if="existComponent">
              <div>
                <spinner
                  legend="Create a definition"
                  :show-spinner="false"
                  :legend-style="{ fontSize: '14px', color: '#444', textAlign: 'center', paddingTop: '20px'}"
                  v-if="!descriptor['id']"/>
                <component 
                  v-if="descriptor.type && showDescriptor"
                  :is="loadComponent + 'Component'"
                  @save="saveDescriptor"
                  :descriptor="descriptor"/>
              </div>
            </template>
          </template>
        </div>
        <div id="cright-panel" v-if="descriptor['id']">
          <preview-component
            class="separate-left"
            :descriptor="descriptor"
            @remove="removeDescriptor"/>
        </div>
      </div>
    </div>
  </div>
</template>
<script>

  import Spinner from 'components/spinner.vue'
  import TypeComponent from './components/type/type.vue'
  import DefinitionComponent from './components/definition/definition.vue'
  import QualitativeComponent from './components/character/character.vue'
  import ContinuousComponent from './components/units/units.vue'
  import PreviewComponent from './components/preview/preview.vue'
  import { CreateDescriptor, UpdateDescriptor, DeleteDescriptor, LoadDescriptor } from './request/resources'

  export default {
    components: {
      QualitativeComponent,
      TypeComponent,
      DefinitionComponent,
      ContinuousComponent,
      PreviewComponent,
      Spinner
    },
    computed: {
      loadComponent() {
        return this.descriptor.type ? this.descriptor.type.split('::')[1] : undefined
      },
      showDescriptor() {
        return !['Sample', 'PresenceAbsence'].includes(this.loadComponent)
      },
      existComponent() {
        return this.$options.components[this.loadComponent + 'Component']
      }
    },
    data() {
      return {
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
    mounted() {
      let descriptorId = location.pathname.split('/')[4]
      if (/^\d+$/.test(descriptorId)) {
        this.loading = true
        LoadDescriptor(descriptorId).then(response => {
          this.descriptor = response
          this.loading = false
        })
      }
    },
    methods: {
      resetDescriptor() {
        this.descriptor = {
          type: undefined,
          name: undefined,
          description: undefined
        }
      },
      saveDescriptor(descriptor) {
        this.saving = true
        if(this.descriptor.hasOwnProperty('id')) {
          UpdateDescriptor(descriptor).then(response => {
            this.descriptor = response;
            this.saving = false
            TW.workbench.alert.create('Descriptor was successfully updated.', 'notice')
          }, rejected=> {
            this.saving = false
          })
        }
        else {
          CreateDescriptor(descriptor).then(response => {
            this.descriptor = response;
            this.saving = false
            history.pushState(null, null, `/tasks/descriptors/new_descriptor/${response.id}`)
            TW.workbench.alert.create('Descriptor was successfully created.', 'notice')
          }, rejected=> {
            this.saving = false
          })
        }
      },
      removeDescriptor(descriptor) {
        DeleteDescriptor(descriptor.id).then(response => {
          this.resetDescriptor()
          history.pushState(null, null, `/tasks/descriptors/new_descriptor/`)
          TW.workbench.alert.create('Descriptor was successfully deleted.', 'notice')
        })
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