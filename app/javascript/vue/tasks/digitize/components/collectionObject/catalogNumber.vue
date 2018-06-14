<template>
  <div>
    <h2>Catalog number</h2>
    <div class="horizontal-left-content">
      <div>
        <label>Namespace</label>
        <autocomplete
          url="/namespaces/autocomplete"
          param="term"/>
      </div>
      <div>
        <label>Identifier</label>
        <input type="text">
      </div>
    </div>
    <label>Preparation</label>
    <ul>
      <li v-for="type in types">
        <label>
          <input
            type="radio"
            name="collection-object-type">
          {{ type }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'
  import { GetPreparationTypes } from '../request/resources'

  export default {
    components: {
      Autocomplete
    },
    mounted() {
      this.updateLabels()
      GetPreparationTypes().then(response => {
        this.types = response
      })
    }
  }
</script>