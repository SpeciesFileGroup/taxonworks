<template>
  <div>
    <h3>Preparation</h3>
    <div class="horizontal-left-content align-start">
      <ul
        v-for="(itemsGroup, index) in preparationGroups"
        :key="index"
        class="no_bullets preparation-list">
        <li
          v-for="type in itemsGroup"
          :key="type.id">
          <label>
            <input
              type="radio"
              :checked="type.id == preparationType"
              :value="type.id"
              v-model="preparationType"
              name="collection-object-type">
            {{ type.name }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import { GetPreparationTypes } from '../request/resources'
export default {
  computed: {
    preparationGroups () {
      return this.preparationTypes.chunk(Math.ceil(this.preparationTypes.length/3))
    },
    preparationType: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  async mounted () {
    this.preparationTypes = (await GetPreparationTypes()).body
    this.preparationTypes.push({
      id: undefined,
      name: 'None'
    })
  },
  data () {
    return {
      preparationTypes: []
    }
  }
}
</script>
