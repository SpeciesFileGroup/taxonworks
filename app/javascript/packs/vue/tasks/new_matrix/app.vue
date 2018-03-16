<template>
  <div id="vue_new_matrix_task">
    <h1>New matrix</h1>
    <new-matrix/>
    <search-component v-if="matrix.id"/>
  </div>
</template>

<script>

import NewMatrix from './components/newMatrix/newMatrix'
import SearchComponent from './components/smartSelector/search.vue'

import { GetterNames } from './store/getters/getters'

export default {
  components: {
    NewMatrix,
    SearchComponent
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    }
  },
  methods: {
  }
}

</script>

