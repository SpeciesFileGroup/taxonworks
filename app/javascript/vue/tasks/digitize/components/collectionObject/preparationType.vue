<template>
  <div>
    <h2>Preparation</h2>
    <ul class="no_bullets">
      <li v-for="type in coTypes">
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
  </div>
</template>

<script>

  import { MutationNames } from '../../store/mutations/mutations.js'
  import { GetterNames } from '../../store/getters/getters.js'
  import { GetPreparationTypes } from '../../request/resources.js'

  export default {
    computed: {
      collectionObjects() {
        return this.$store.getters[GetterNames.GetCollectionObjects]
      },
      preparationType: {
        get() {
          return this.$store.getters[GetterNames.GetPreparationType]
        },
        set(value) {
          this.$store.commit(MutationNames.SetPreparationType, value)
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
    },
    mounted() {
      GetPreparationTypes().then(response => {
        this.coTypes = response
      })
    }
  }
</script>

<style>

</style>
