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
      class="flex-wrap-column middle margin-medium-top">
      <div
        @click="flipValues"
        class="flip-container cursor-pointer"
        data-icon="swap"/>
      Flip
    </div>
  </div>
</template>

<script>

import PropertyBox from './PropertyBox'
import RelationshipBox from './Relationship'
import { CreateBiologicalRelationship, UpdateBiologicalRelationship } from '../../request/resource'

export default {
  components: {
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
    setBiologicalRelationship(newVal) {
      this.biological_relationship.id = newVal.id
      this.biological_relationship.name = newVal.name
      this.biological_relationship.inverted_name = newVal.inverted_name
      this.biological_relationship.is_transitive = newVal.is_transitive
      this.biological_relationship.is_reflexive = newVal.is_reflexive
      this.object = newVal.object_biological_properties.map(item => { item.created = true; return item })
      this.subject = newVal.subject_biological_properties.map(item => { item.created = true; return item })
    },
    flipValues () {
      if (!this.biologicalRelationship.id) return
      const tmp = this.object
      
      this.object = this.subject
      this.subject = tmp
      this.flip = !this.flip
    },
    saveBiologicalRelationship () {
      const object = this.object.filter(item => { return !item['created'] }).map(item => { return { type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType', biological_property_id: item.id } })
      const subject = this.subject.filter(item => { return !item['created'] }).map(item => { return { type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType', biological_property_id: item.id } })
      
      let data = this.biological_relationship
      
      data.biological_relationship_types_attributes = subject.concat(object)
      if(data.id) {
        UpdateBiologicalRelationship(data).then(response => {
          this.$emit('update', response.body)
          this.reset()
          TW.workbench.alert.create('Biological relationship was successfully updated.', 'notice')
        })
      }
      else {
        CreateBiologicalRelationship(data).then(response => {
          this.setBiologicalRelationship(response.body)
          this.$emit('update', response.body)
          TW.workbench.alert.create('Biological relationship was successfully created.', 'notice')
        })
      }
    },
    reset () {
      this.biological_relationship = {
        id: undefined,
        name: undefined,
        inverted_name: undefined,
        is_transitive: undefined,
        is_reflexive: undefined
      }
      this.object = []
      this.subject = []
    }
  }
}
</script>

<style lang="scss" scoped>
  .flip-container {
    height: 70px;
    width: 70px;
    padding: 0px;
    background-size: 60px !important;
    background-position: center;
  }
  .flip-container:hover {
    animation-name: spin;
    animation-duration: 1000ms;
    animation-iteration-count: 1;
    animation-fill-mode: forwards;
    //animation-timing-function: linear;
  }
  @keyframes spin {
    from {
      transform: rotateY(0deg);
    } to {
      transform: rotateY(180deg);
    }
  }
</style>