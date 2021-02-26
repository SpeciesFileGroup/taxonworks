<template>
  <div
    v-if="softValidation.length"
    class="panel content soft-validation-box validation-warning">
    <div class="margin-medium-left">
      <h3>Soft validation</h3>
    </div>
    <div class="body">
      <ul class="no_bullets">
        <li v-for="item in softValidation">
          <span data-icon="warning" v-html="item.message"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'

export default {
  computed: {
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation]
    }
  }
}
</script>
