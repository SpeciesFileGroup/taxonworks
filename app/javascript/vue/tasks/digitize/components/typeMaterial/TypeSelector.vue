<template>
  <div class="separate-bottom">
    <p>Type type</p>
    <ul class="no_bullets">
      <template
        v-for="(item, key) in typeList"
        :key="key">
        <li>
          <label>
            <input
              class="capitalize"
              type="radio"
              v-model="type"
              :value="key">
            {{ key }}
          </label>
        </li>
      </template>
    </ul>
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { TypeMaterial } from 'routes/endpoints'

export default {
  props: {
    modelValue: {
      type: String
    }
  },

  emits: ['update:modelValue'],

  computed: {
    nomenclatureCode () {
      return this.$store.getters[GetterNames.GetTypeMaterial].taxon?.nomenclatural_code
    },

    typeList () {
      return this.types[this.nomenclatureCode]
    },

    type: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data: () => ({
    types: {}
  }),

  created () {
    TypeMaterial.types().then(response => {
      this.types = response.body
    })
  }
}
</script>
