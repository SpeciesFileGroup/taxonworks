<template>
  <div
    v-if="errors.length"
    :class="{ 'validation-warning' : errors }"
    class="panel content soft-validation-box-type">
    <div class="header flex-separate">
      <h3>Soft Validation</h3>
    </div>
    <div class="body">
      <div>
        <ul class="no_bullets">
          <li
            v-for="(error, key) in errors"
            :key="key">
            <span data-icon="warning" />
            <span v-html="error.message" />
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'

export default {
  computed: {
    errors () {
      return this.$store.getters[GetterNames.GetSoftValidation]
    }
  }
}
</script>

<style lang="scss">
  .soft-validation-box-type.validation-warning {
    border-left: 4px solid #ff8c00;
  }
  .soft-validation-box-type {
    background-color: #FFF9F9;
    .body {
     padding: 12px;
   }
   .header {
     padding-left: 12px;
     padding-right: 12px;
   }
   ul {
     margin: 0px;
     padding: 0px;
   }
   li {
     margin-top: 12px;
   }
   li:first-letter {
     text-transform: capitalize;
   }
  }
</style>
