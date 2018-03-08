<template>
  <div>
    <h1>New descriptor</h1>
    <type-component v-model="descriptor.type"/>
    <template v-if="descriptor.type">
      <definition-component/>
      <template v-if="existComponent">
        <component v-if="descriptor.type && showDescriptor" :is="loadComponent + 'Component'"/>
      </template>
      <create-component v-else/>
    </template>
  </div>
</template>
<script>

  import TypeComponent from './components/type/type.vue'
  import DefinitionComponent from './components/definition/definition.vue'
  import QualitativeComponent from './components/character/character.vue'
  import ContinuousComponent from './components/units/units.vue'
  import CreateComponent from './components/save/save.vue'

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
          define
        }
      }
    }
  }
</script>