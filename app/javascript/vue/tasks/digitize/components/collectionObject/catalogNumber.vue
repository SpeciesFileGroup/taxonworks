<template>
  <div>
    <h2>Catalog number</h2>
    <div class="horizontal-left-content">
      <div class="separate-right">
        <label>Namespace</label>
        <br>
        <autocomplete
          url="/namespaces/autocomplete"
          min="2"
          @getItem="namespace = $event.id"
          label="label_html"
          param="term"/>
      </div>
      <div class="separate-left">
        <label>Identifier</label>
        <br>
        <input
          type="text"
          v-model="identifier">
      </div>
    </div>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetterNames } from '../../store/getters/getters.js'
  import { MutationNames } from '../../store/mutations/mutations.js'

  export default {
    components: {
      Autocomplete
    },
    computed: {
      collectionObjects() {
        return this.$store.getters[GetterNames.GetCollectionObjects]
      },
      namespace: {
        get() {
          return this.$store.getters[GetterNames.GetIdentifier].namespace_id
        },
        set(value) {
          this.$store.commit(MutationNames.SetIdentifierNamespaceId, value)
        },
      },
      identifier: {
        get() {
          return this.$store.getters[GetterNames.GetIdentifier].identifier
        },
        set(value) {
          return this.$store.commit(MutationNames.SetIdentifierIdentifier, value)
        }
      },
      coTypes: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObjectTypes]
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectTypes, value)
        }
      }
    }
  }
</script>