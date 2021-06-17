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

import { PreparationType } from 'routes/endpoints'

export default {
  props: {
    modelValue: {
      type: [String, Number],
      default: undefined
    }
  },

  computed: {
    preparationGroups () {
      return this.preparationTypes.chunk(Math.ceil(this.preparationTypes.length/3))
    },

    preparationType: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  async mounted () {
    this.preparationTypes = (await PreparationType.all()).body
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
