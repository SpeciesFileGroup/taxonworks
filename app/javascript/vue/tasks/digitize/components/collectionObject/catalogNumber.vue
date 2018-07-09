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
          param="term"/>
      </div>
      <div class="separate-left">
        <label>Identifier</label>
        <br>
        <input type="text">
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
            name="collection-object-type">
          {{ type.name }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetPreparationTypes } from '../../request/resources.js'

  export default {
    components: {
      Autocomplete
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