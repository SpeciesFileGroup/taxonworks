<template>
  <div>
    <h3>Preparation</h3>
    <div class="flex-separate align-start">
      <template v-for="(itemsGroup, index) in preparationTypes.chunk(Math.ceil(preparationTypes.length/2))">
        <ul
          class="no_bullets"
          :key="index">
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

import { GetPreparationTypes } from '../../request/resources'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      type: Array,
      required: true
    }
  },

  data () {
    return {
      preparationTypes: []
    }
  },

  computed: {
    selected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },

  async created () {
    this.preparationTypes = (await GetPreparationTypes()).body
    this.selected = URLParamsToJSON(location.href).preparation_type_id || []
  }
}
</script>
