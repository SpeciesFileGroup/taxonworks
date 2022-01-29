<template>
  <div
    class="field"
  >
    <label v-html="predicateObject.object_tag" />
    <autocomplete
      :url="`/data_attributes/value_autocomplete`"
      v-model="data_attribute.value"
      @getItem="data_attribute.value = $event"
      :add-params="{
        predicate_id: this.predicateObject.id
      }"
      param="term"/>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'

export default {
  components: {
    Autocomplete
  },
  props: {
    predicateObject: {
      type: Object,
      required: true
    },

    objectId: {
      type: [String, Number]
    },

    objectType: {
      type: String,
      required: true
    },

    existing: {
      type: Object,
      default: undefined
    }
  },

  emits: ['onUpdate'],

  data () {
    return {
      data_attribute: this.newDataAttribute()
    }
  },

  watch: {
    existing (newVal) {
      this.data_attribute = newVal || this.newDataAttribute()
    },

    data_attribute: {
      handler () {
        this.updatePredicate()
      },
      deep: true
    },

    objectId (newVal) {
      if (!newVal) {
        this.data_attribute.value = undefined
      }
    }
  },

  methods: {
    newDataAttribute () {
      return {
        type: 'InternalAttribute',
        controlled_vocabulary_term_id: this.predicateObject.id,
        attribute_subject_id: this.objectId,
        attribute_subject_type: this.objectType,
        value: undefined
      }
    },

    updatePredicate () {
      let data

      if (!this.data_attribute?.value?.length && this.data_attribute?.id) {
        data = {
          id: this.data_attribute.id,
          _destroy: true
        }
      } else {
        data = this.data_attribute
      }
      this.$emit('onUpdate', data)
    }
  }

}
</script>