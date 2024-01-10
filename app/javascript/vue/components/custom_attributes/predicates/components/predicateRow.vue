<template>
  <div class="field">
    <label v-html="predicateObject.object_tag" />
    <autocomplete
      v-model="data_attribute.value"
      :url="`/data_attributes/value_autocomplete`"
      :add-params="{
        predicate_id: this.predicateObject.id
      }"
      param="term"
      @get-item="
        (value) => {
          data_attribute.value = value
          updatePredicate()
        }
      "
      @change="updatePredicate"
    />
  </div>
</template>

<script>
import Autocomplete from '@/components/ui/Autocomplete'

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

  data() {
    return {
      data_attribute: this.newDataAttribute()
    }
  },

  watch: {
    existing(newVal) {
      this.data_attribute = newVal || this.newDataAttribute()
    },

    objectId(newVal) {
      if (!newVal) {
        this.data_attribute.value = undefined
      }
    }
  },

  methods: {
    newDataAttribute() {
      return {
        type: 'InternalAttribute',
        controlled_vocabulary_term_id: this.predicateObject.id,
        attribute_subject_id: this.objectId,
        attribute_subject_type: this.objectType,
        value: undefined
      }
    },

    updatePredicate() {
      const value = this.data_attribute?.value?.trim()
      const id = this.data_attribute.id

      if (!value) {
        if (id) {
          this.$emit('onUpdate', {
            id,
            controlled_vocabulary_term_id: this.predicateObject.id,
            _destroy: true
          })
        }
      } else {
        this.$emit('onUpdate', this.data_attribute)
      }
    }
  }
}
</script>
