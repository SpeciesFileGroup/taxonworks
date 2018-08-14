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
    <label>Preparation</label>
    <br>
    <ul>
      <li v-for="type in types">
        <label>
          <input
            type="radio"
            :value="type.id"
            v-model="preparationType"
            name="collection-object-type">
          {{ type.name }}
        </label>
      </li>
    </ul>
    <br>
    <label>Total</label>
    <br>
    <input
      type="number"
      v-model="total">
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetPreparationTypes } from '../../request/resources.js'
  import { GetterNames } from '../../store/getters/getters.js'
  import { MutationNames } from '../../store/mutations/mutations.js'

  export default {
    components: {
      Autocomplete
    },
    computed: {
      namespace: {
        get() {
          return this.$store.getters[GetterNames.GetIdentifier].namespace_id
        },
        set(value) {
          this.$store.commit(MutationNames.SetIdentifierNamespaceId, value)
        }
      },
      preparationType: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObject].preparation_type_id
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectPreparationId, value)
        }
      },
      identifier: {
        get() {
          return this.$store.getters[GetterNames.GetIdentifier].identifier
        },
        set(value) {
          return this.$store.commit(MutationNames.SetIdentifierIdentifier, value)
        }
      },
      total: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObject].total
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectTotal, value)
        }
      }
    },
    data() {
      return {
        types: []
      }
    },
    mounted() {
      GetPreparationTypes().then(response => {
        this.types = response
      })
    }
  }
</script>