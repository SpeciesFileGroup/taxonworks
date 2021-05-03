<template>
  <div class="flex-wrap-column middle">
    <h2>Edit</h2>
    <button
      @click="saveBiologicalRelationship"
      type="button"
      :disabled="!validate"
      class="button normal-input button-submit">
      {{ biological_relationship.id ? 'Update' : 'Create' }}
    </button>

    <div class="horizontal-center-content full_width middle margin-small-top">
      <property-box
        v-model="subject"/>
      <relationship-box
        :flip="flip"
        v-model="biological_relationship"/>
      <property-box
        v-model="object"/>
    </div>
    <div
      v-if="biological_relationship.id"
      class="flex-wrap-column middle margin-medium-top margin-large-bottom">
      <div
        @click="flipValues"
        class="flip-container cursor-pointer"
        data-icon="swap"/>
      Flip
    </div>
    <h2 class="margin-large-top">Examples</h2>
    <preview-table
      :subject-string="flip ? objectString : subjectString"
      :object-string="flip ? subjectString : objectString"
      :biological-relationship="biologicalRelationship"/>
  </div>
</template>

<script>

import PropertyBox from './PropertyBox'
import RelationshipBox from './Relationship'
import PreviewTable from './PreviewTable'
import { BiologicalRelationship } from 'routes/endpoints'

export default {
  components: {
    PreviewTable,
    PropertyBox,
    RelationshipBox
  },
  props: {
    biologicalRelationship: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    validate () {
      return this.biological_relationship.name
    },

    objectString () {
      return this.object.filter(item => !item?._destroy).map(item => item?.biological_property?.name || item.name).join(', ')
    },

    subjectString () {
      return this.subject.filter(item => !item?._destroy).map(item => item?.biological_property?.name || item.name).join(', ')
    }
  },

  data () {
    return {
      flip: false,
      object: [],
      subject: [],
      biological_relationship: undefined
    }
  },

  watch: {
    biologicalRelationship: {
      handler (newVal) {
        this.setBiologicalRelationship(newVal)
      }
    }
  },

  created () {
    this.reset()
  },

  methods: {
    setBiologicalRelationship (newVal) {
      this.biological_relationship.id = newVal.id
      this.biological_relationship.name = newVal.name
      this.biological_relationship.definition = newVal.definition
      this.biological_relationship.inverted_name = newVal.inverted_name
      this.biological_relationship.is_transitive = newVal.is_transitive
      this.biological_relationship.is_reflexive = newVal.is_reflexive
      this.object = newVal.object_biological_relationship_types.map(item => ({ ...item, created: true }))
      this.subject = newVal.subject_biological_relationship_types.map(item => ({ ...item, created: true }))
    },
    flipValues () {
      if (!this.biologicalRelationship.id) return
      const tmp = this.object

      this.object = this.subject
      this.subject = tmp
      this.flip = !this.flip
    },
    saveBiologicalRelationship () {
      const object = this.object.filter(item => !item?.created).map(item => ({ type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType', biological_property_id: item?.biological_property_id || item.id }))
      const subject = this.subject.filter(item => !item?.created).map(item => ({ type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType', biological_property_id: item?.biological_property_id || item.id }))
      const removed = this.getDestroyed(this.subject).concat(this.getDestroyed(this.object))
      const data = this.biological_relationship

      data.biological_relationship_types_attributes = subject.concat(object, removed)

      if (data.id) {
        BiologicalRelationship.update(data.id, { biological_relationship: data }).then(response => {
          this.$emit('update', response.body)
          TW.workbench.alert.create('Biological relationship was successfully updated.', 'notice')
        })
      }
      else {
        BiologicalRelationship.create({ biological_relationship: data }).then(response => {
          this.setBiologicalRelationship(response.body)
          this.$emit('update', response.body)
          TW.workbench.alert.create('Biological relationship was successfully created.', 'notice')
        })
      }
    },

    getDestroyed (value) {
      return value.filter(item => item?._destroy).map(item => ({ _destroy: item._destroy, id: item.id }))
    },

    reset () {
      this.biological_relationship = {
        id: undefined,
        name: undefined,
        inverted_name: undefined,
        is_transitive: undefined,
        is_reflexive: undefined,
        definition: undefined
      }
      this.object = []
      this.subject = []
    }
  }
}
</script>

<style lang="scss" scoped>
  .flip-container {
    height: 35px;
    width: 35px;
    padding: 0px;
    background-size: 35px !important;
    background-position: center;
  }
</style>