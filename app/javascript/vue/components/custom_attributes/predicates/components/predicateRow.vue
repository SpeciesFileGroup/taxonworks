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
      data_attribute: this.newDataAttribute() 
    }
  },
  watch: {
    existing(newVal) {
      if(newVal) {
        this.data_attribute = newVal
      }
      else {
        this.data_attribute = this.newDataAttribute()
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
        value: this.value
      }
    },
    updatePredicate() {
      let data

      if(this.data_attribute.value.length == 0 && this.data_attribute.hasOwnProperty('id')) {
        data = {
          id: this.data_attribute.id,
          _destroy: true
        }
      }
      else {
        data = this.data_attribute
      }
      
      this.$emit('onUpdate', data)
    }
  }

}
</script>

<style scoped>
  input {
    width: 100%;
  }
</style>