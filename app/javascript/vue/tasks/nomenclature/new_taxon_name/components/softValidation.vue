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
        v-if="errors[key].list.length"
        :key="key">
        <h3>
          {{ errors[key].title }}
          <button
            v-if="getFixPresent(errors[key].list).length"
            type="button"
            class="button button-submit margin-small-left"
            @click="runFix(getFixPresent(errors[key].list))">
            <span>Fix all</span>
          </button>
        </h3>
        <ul
          v-for="list in errors[key].list"
          class="no_bullets">
          <li
            class="horizontal-left-content align-start"
            v-for="(error, index) in list.soft_validations"
            :key="index">
            <tippy-component
              animation="scale"
              placement="bottom"
              size="small"
              inertia
              arrow
              :content="error.description">
              <template slot="trigger">
                <span data-icon="warning"/>
              </template>
            </tippy-component>
            <span>
              <button
                v-if="error.fixable"
                type="button"
                class="button button-submit"
                @click="runFix([{ global_id: list.global_id, only_methods: [error.soft_validation_method] }])">
                Fix
              </button>
              <span>
                {{ error.message }}
                <template v-for="(resolution, index) in error.resolution">
                  <tippy-component
                    class="d-inline-block"
                    animation="scale"
                    placement="bottom"
                    size="small"
                    :key="index"
                    inertia
                    arrow
                    content="Fixable here (may leave page)">
                    <template slot="trigger">
                      <a :href="resolution">
                        <span class='small-icon icon-without-space' data-icon='blue_wrench'/></a>
                    </template>
                  </tippy-component>
                </template>
              </span>
            </span>
          </li>
        </ul>
        <hr>
      </div>
    </div>
  </div>

</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { SoftValidationFix } from '../request/resources'
import { TippyComponent } from 'vue-tippy'

export default {
  components: { TippyComponent },

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
          only_methods: item.soft_validations
            .filter(v => v.fixable)
            .map(item => item.soft_validation_method)
        }))
        .filter(item => item.only_methods.length)
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
