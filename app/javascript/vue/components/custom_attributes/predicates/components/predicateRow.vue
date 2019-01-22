<template>
  <div
    class="field"
  >
    <label v-html="predicateObject.object_tag" />
    <input
      type="text"
      v-model="data_attribute.value"
      @change="updatePredicate"
    >
  </div>
</template>

<script>
export default {
  props: {
    predicateObject: {
      type: Object,
      required: true
    },
    objectId: {
      required: true,
      validator(value) {
        return value === undefined || typeof value === 'string' || typeof value === 'number'
      }
    },
    objectType: {
      type: String,
      required: true
    },
    existing: {
      type: Object,
      required: false
    }
  },
  data() {
    return {
      data_attribute: {
        type: 'InternalAttribute',
        controlled_vocabulary_term_id: this.predicateObject.id,
        attribute_subject_id: this.objectId,
        attribute_subject_type: this.objectType,
        value: this.value
      }
    }
  },
  watch: {
    existing(newVal) {
      if(newVal) {
        this.data_attribute = newVal
      }
    }
  },
  methods: {
    updatePredicate() {
      this.$emit('onUpdate', this.data_attribute)
    }
  }

}
</script>
