<template>
  <div>
    <h1>New descriptor</h1>
    <type-component v-model="descriptor.type"/>
    <definition-component v-if="descriptor.type"/>
    <template>
      <template v-if="existComponent">
        <component v-if="descriptor.type && showDescriptor" :is="loadComponent + 'Component'"/>
      </template>
      <create-definition/>
    </template>
  </div>
</template>
<script>

  import TypeComponent from './components/type/type.vue'
  import DefinitionComponent from './components/definition/definition.vue'
  import QualitativeComponent from './components/character/character.vue'
  import CreateDefinition from './components/character/character.vue'

  export default {
    components: {
      QualitativeComponent,
      TypeComponent,
      DefinitionComponent,
      CreateDefinition
    },
    computed: {
      loadComponent() {
        return this.descriptor.type.split('::')[1]
      },
      showDescriptor() {
        return !['Sample', 'PresenceAbsence'].includes(this.loadComponent)
      },
      existComponent() {
        return this.$options.components[this.loadComponent]
      }
    },
    data() {
      return {
        descriptor: {
          type: undefined
        }
      }
    }
  }
</script>