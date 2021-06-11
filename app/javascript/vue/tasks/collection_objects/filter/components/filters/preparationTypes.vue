<template>
  <div>
    <h3>Preparation</h3>
    <div class="flex-separate align-start">
      <template
        v-for="(itemsGroup, index) in preparationTypes.chunk(Math.ceil(preparationTypes.length/2))"
        :key="index">
        <ul class="no_bullets">
          <li
            v-for="type in itemsGroup"
            :key="type.id">
            <label>
              <input
                type="checkbox"
                :value="type.id"
                v-model="selected"
                name="collection-object-type">
              {{ type.name }}
            </label>
          </li>
        </ul>
      </template>
    </div>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'
import { sortArray } from 'helpers/arrays'
import { PreparationType } from 'routes/endpoints'

export default {
  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      preparationTypes: []
    }
  },

  computed: {
    selected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  async created () {
    this.preparationTypes = sortArray((await PreparationType.all()).body, 'name')
    this.selected = URLParamsToJSON(location.href).preparation_type_id || []
  }
}
</script>
