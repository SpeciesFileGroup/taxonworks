<template>
  <div>
    <h3>Types</h3>
    <h4>Nomenclature code</h4>
    <div class="field">
      <ul class="no_bullets">
        <li
          v-for="(group, key) in types"
          :key="key">
          <label class="uppercase">
            <input 
              type="radio"
              :value="key"
              name="nomenclature-code-type"
              v-model="nomenclature_code">
            {{ key }}
          </label>
        </li>
      </ul>
    </div>
    <div
      v-if="nomenclature_code"
      class="field">
      <h4>Types</h4>
      <ul class="no_bullets">
        <li v-for="(item, type) in types[nomenclature_code]">
          <label class="capitalize">
            <input
              v-model="selectedTypes.is_type"
              :value="type"
              name="type-type"
              type="checkbox">
            {{ type }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TypeMaterial } from 'routes/endpoints'

export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  computed: {
    selectedTypes: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  emits: ['update:modelValue'],

  watch: {
    nomenclature_code() {
      this.selectedTypes.is_type = []
    }
  },
  data () {
    return {
      nomenclature_code: undefined,
      types: {}
    }
  },
  mounted () {
    TypeMaterial.types().then(response => {
      this.types = response.body
    })
    const urlParams = URLParamsToJSON(location.href)
    this.selectedTypes.is_type = urlParams.is_type ? urlParams.is_type : []
  }
}
</script>
