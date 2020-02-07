<template>
  <div class="flex-wrap-column middle">
    <h2>Edit</h2>
    <button
      @click="createBiologicalRelationship"
      type="button"
      :disabled="!validate"
      class="button normal-input button-submit">
      Update
    </button>

    <div class="flex-separate full_width middle">
      <property-box
        v-model="subject"/>
      <relationship-box 
        :flip="flip"
        v-model="biological_relationship"/>
      <property-box
        v-model="object"/>
    </div>
    <div class="flex-wrap-column middle margin-medium-top">
      <div
        @click="flipValues"
        class="flip-container cursor-pointer"
        data-icon="reset"/>
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
      return this.object && this.subject && this.biological_relationship.name && this.biological_relationship.id
    }
  },
  data () {
    return {
      flip: false,
      object: undefined,
      subject: undefined,
      biological_relationship: undefined
    }
  },
  watch: {
    biologicalRelationship: {
      handler (newVal) {
        this.biological_relationship.id = newVal.id
        this.biological_relationship.name = newVal.name
        this.biological_relationship.inverted_name = newVal.inverted_name
        this.biological_relationship.is_transitive = newVal.is_transitive
        this.biological_relationship.is_reflexive = newVal.is_reflexive
      }
    }
  },
  created () {
    this.reset()
  },
  methods: {
    flipValues () {
      const tmp = this.object
      
      this.object = this.subject
      this.subject = tmp
      this.flip = !this.flip
    },
    createBiologicalRelationship () {
      const object = { type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType', biological_property_id: this.object.id }
      const subject = { type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType', biological_property_id: this.subject.id }
      
      let data = this.biological_relationship
      
      data.biological_relationship_types_attributes = [subject, object]
      UpdateBiologicalRelationship(data).then(response => {
        this.reset()
        TW.workbench.alert.create('Biological relationship was successfully created.', 'notice')
      })
    },
    reset () {
      this.biological_relationship = {
        id: undefined,
        name: undefined,
        inverted_name: undefined,
        is_transitive: undefined,
        is_reflexive: undefined
      }
      this.object = undefined
      this.subject = undefined
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
    animation-iteration-count: infinite;
    animation-timing-function: linear;
  }
  @keyframes spin {
    from {
      transform: rotate(0deg);
    } to {
      transform: rotate(360deg);
    }
  }
</style>