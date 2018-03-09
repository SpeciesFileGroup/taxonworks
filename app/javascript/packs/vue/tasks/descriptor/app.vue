<template>
  <div>
    <h1>New descriptor</h1>
    <type-component 
    :descriptor-id="descriptor['id']"
    v-model="descriptor.type"/>
    <template v-if="descriptor.type">
      <definition-component 
      :name="descriptor.name"
      :description="descriptor.description"
      @onNameChange="descriptor.name = $event"
      @onDescriptionChange="descriptor.description = $event"/>
      <create-component 
        :descriptor="descriptor"
        @save="saveDescriptor(descriptor)"/>
      <template v-if="existComponent">
        <component 
          v-if="descriptor.type && showDescriptor" :is="loadComponent + 'Component'"
          :descriptor="descriptor"/>
      </template>
    </template>
  </div>
</template>
<script>

  import TypeComponent from './components/type/type.vue'
  import DefinitionComponent from './components/definition/definition.vue'
  import QualitativeComponent from './components/character/character.vue'
  import ContinuousComponent from './components/units/units.vue'
  import CreateComponent from './components/save/save.vue'
  import { CreateDescriptor, UpdateDescriptor } from './request/resources'

  export default {
    components: {
      QualitativeComponent,
      TypeComponent,
      DefinitionComponent,
      ContinuousComponent,
      CreateComponent
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
          description: undefined
        }
      }
    },
    methods: {
      saveDescriptor(descriptor) {
        if(this.descriptor.hasOwnProperty('id')) {
          UpdateDescriptor(descriptor).then(response => {
            this.descriptor = response;
          })
        }
        else {
          CreateDescriptor(descriptor).then(response => {
            this.descriptor = response;
          })
        }
      }
    }
  }
</script>