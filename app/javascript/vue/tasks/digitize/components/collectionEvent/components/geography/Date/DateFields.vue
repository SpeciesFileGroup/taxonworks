<template>
  <div>
    <label><b>{{ title }}</b></label>
    <div class="horizontal-left-content">
      <div
        v-for="(field, index) in fields"
        :key="field.property"
        class="separate-right">
        <label>{{ field.label }}</label>
        <input
          :id="field.id"
          type="text"
          :ref="el => { if (el) fieldsRef[index] = el }"
          :maxlength="field.maxLength"
          v-model="collectingEvent[field.property]"
          @input="autoAdvance(index)">
      </div>
    </div>
  </div>
</template>

<script>
import { GetterNames } from '../../../../../store/getters/getters.js'
import { MutationNames } from '../../../../../store/mutations/mutations.js'

export default {
  props: {
    fields: {
      type: Array,
      required: true
    },

    title: {
      type: String,
      required: true
    }
  },

  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionEvent, value)
      }
    }
  },

  data () {
    return {
      fieldsRef: []
    }
  },

  methods: {
    autoAdvance (index) {
      const element = this.fieldsRef[index]
      const maxLength = element.getAttribute('maxlength')

      index++

      if (element.value.length === Number(maxLength) && this.fieldsRef.length > index) {
        this.fieldsRef[index].focus()
      }
    }
  }
}
</script>

<style scoped>
  input {
    max-width: 60px;
  }
</style>
