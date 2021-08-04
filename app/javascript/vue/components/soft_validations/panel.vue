<template>
  <div
    v-if="validationSections.length"
    class="panel content soft-validation-box validation-warning">
    <div class="header flex-separate">
      <h3>Soft Validation</h3>
    </div>
    <div
      class="body overflow-y-auto">
      <template
        v-for="(section, index) in validationSections"
        :key="index">
        <div>
          <h3>
            <span v-if="section.title">{{ section.title }}</span>
            <button
              v-if="getFixPresent(section.list).length"
              type="button"
              class="button button-submit margin-small-left"
              @click="runFix(getFixPresent(section.list))">
              <span>Fix all</span>
            </button>
          </h3>
          <ul
            v-for="list in section.list"
            class="no_bullets">
            <li
              class="horizontal-left-content align-start"
              v-for="(error, index) in list.soft_validations"
              :key="index">
              <tippy
                animation="scale"
                placement="bottom"
                size="small"
                inertia
                arrow
                :content="error.description">
                <span data-icon="warning"/>
              </tippy>
              <span>
                <button
                  v-if="error.fixable"
                  type="button"
                  class="button button-submit"
                  @click="runFix([{ global_id: list.instance.global_id, only_methods: [error.soft_validation_method] }])">
                  Fix
                </button>
                <span>
                  <span v-html="error.message" />
                  <template
                    v-for="(resolution, rIndex) in error.resolution"
                    :key="rIndex">
                    <tippy
                      class="d-inline-block"
                      animation="scale"
                      placement="bottom"
                      size="small"
                      inertia
                      arrow
                      content="Fixable here (may leave page)">
                      <a :href="resolution">
                        <span
                          class="small-icon icon-without-space"
                          data-icon="blue_wrench"
                        />
                      </a>
                    </tippy>
                  </template>
                </span>
              </span>
            </li>
          </ul>
          <hr v-if="index !== (validationSections.length-1)">
        </div>
      </template>
    </div>
  </div>
</template>

<script>

import { SoftValidation } from 'routes/endpoints'
import { Tippy } from 'vue-tippy'

export default {
  components: { Tippy },

  props: {
    validations: {
      type: Object,
      required: true
    }
  },

  computed: {
    validationSections () {
      return Object.values(this.validations).filter(item => item.list.length)
    }
  },

  methods: {
    runFix (fixItems) {
      const promises = []

      fixItems.forEach(params => { promises.push(SoftValidation.fix(params.global_id, params)) })

      Promise.all(promises).then(() => {
        location.reload()
      })
    },

    getFixPresent (list) {
      return list.map(item =>
        Object.assign({}, {
          global_id: item.instance.global_id,
          only_methods: item.soft_validations
            .filter(v => v.fixable)
            .map(item => item.soft_validation_method)
        }))
        .filter(item => item.only_methods.length)
    }
  }
}
</script>
<style lang="scss" scope>
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
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
  }

</style>
