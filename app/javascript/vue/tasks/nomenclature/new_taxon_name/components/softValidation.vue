<template>
  <div
    v-if="checkSoftValidation()"
    :class="{ 'validation-warning' : errors }"
    class="panel content soft-validation-box">
    <div class="header flex-separate">
      <h3>Soft Validation</h3>
    </div>
    <div
      class="body overflow-y-auto">
      <div
        v-for="key in Object.keys(errors)"
        v-if="errors[key].list.length">
        <hr>
        <h3>
          {{ errors[key].title }}
          <button
            v-if="getFixPresent(errors[key].list).length"
            type="button"
            class="button button-submit margin-small-left"
            @click="runFix(errors[key].list.map(({ global_id }) => ({ global_id }) ))">
            Fix all
          </button>
        </h3>
        <hr>
        <ul
          v-for="list in errors[key].list"
          class="no_bullets">
          <li v-for="error in list.validations.soft_validations">
            <span data-icon="warning"/>
            <button
              v-if="error.fix"
              type="button"
              class="button button-submit"
              @click="runFix([{ global_id: list.global_id, fix: [error.soft_validation_method] }])">
              Fix
            </button>
            <span v-html="error.message"/>
          </li>
        </ul>
      </div>
    </div>
  </div>

</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { SoftValidationFix } from '../request/resources'

export default {
  computed: {
    errors () {
      return this.$store.getters[GetterNames.GetSoftValidation]
    }
  },
  methods: {
    checkSoftValidation () {
      return (this.errors.taxon_name.list.length ||
      this.errors.taxonStatusList.list.length ||
      this.errors.taxonRelationshipList.list.length)
    },

    runFix (fixItems) {
      const promises = []

      fixItems.forEach(params => { promises.push(SoftValidationFix(params)) })

      Promise.all(promises).then(() => {
        location.reload()
      })
    },

    getFixPresent (list) {
      return list.map(item =>
        Object.assign({}, {
          global_id: item.global_id,
          key: item.validations.soft_validations
            .filter(v => v.fix)
            .map(item => item.fix)
        }))
        .filter(item => item.key.length)
    }
  }
}
</script>
<style lang="scss">
  .soft-validation-box.validation-warning {
    border-left: 4px solid #ff8c00;
  }
  .soft-validation-box {
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
