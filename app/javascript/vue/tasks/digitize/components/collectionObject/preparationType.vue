<template>
  <div>
    <h2>Preparation</h2>
    <div class="horizontal-left-content align-start">
      <ul
        v-for="itemsGroup in coTypes.chunk(Math.ceil(coTypes.length/3))"
        class="no_bullets preparation-list">
        <li v-for="type in itemsGroup">
          <label>
            <input
              type="radio"
              :checked="type.id == preparationType"
              :value="type.id"
              v-model="preparationType"
              name="collection-object-type">
            {{ type.name }}
          </label>
        </li>
      </ul>
      <lock-component v-model="locked.collection_object.preparation_type_id"/>
    </div>
  </div>
</template>

<script>

  import { MutationNames } from '../../store/mutations/mutations.js'
  import { GetterNames } from '../../store/getters/getters.js'
  import { GetPreparationTypes } from '../../request/resources.js'
  import LockComponent from 'components/lock'

  export default {
    components: {
      LockComponent
    },
    computed: {
      locked: {
        get() {
          return this.$store.getters[GetterNames.GetLocked]
        },
        set(value) {
          this.$store.commit(MutationNames.SetLocked, value)
        }
      },
      collectionObjects() {
        return this.$store.getters[GetterNames.GetCollectionObjects]
      },
      preparationType: {
        get() {
          return this.$store.getters[GetterNames.GetCollectionObject].preparation_type_id
        },
        set(value) {
          this.$store.commit(MutationNames.SetCollectionObjectPreparationId, value)
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
        this.coTypes = response.body
        this.coTypes.unshift(
          {
            id: null,
            name: 'None'
          })
      })
    }
  }
</script>

<style scoped>
  .preparation-list {
    width: 100%;
  }
</style>
