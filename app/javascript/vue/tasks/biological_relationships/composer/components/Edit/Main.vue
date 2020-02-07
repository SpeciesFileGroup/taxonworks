<template>
  <div class="flex-wrap-column middle">
    <h2>Edit</h2>
    <button
      type="button"
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
  </div>
</template>

<script>

import PropertyBox from './PropertyBox'
import RelationshipBox from './Relationship'

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

  },
  data () {
    return {
      flip: false,
      object: undefined,
      subject: undefined,
      biological_relationship: {
        name: undefined, 
        inverted_name: undefined, 
        is_transitive: undefined, 
        is_reflexive: undefined ,
        biological_relationship_types: []
      }
    }
  },
  watch: {
    biologicalRelationship: {
      handler(newVal) {
        this.biological_relationship.name = newVal.name
        this.biological_relationship.inverted_name = newVal.inverted_name
        this.biological_relationship.is_transitive = newVal.is_transitive
        this.biological_relationship.is_reflexive = newVal.is_reflexive
      }
    }
  },
  methods: {
    flipValues () {
      let tmp = this.object
      
      this.object = this.subject
      this.subject = tmp
      this.flip = !this.flip
    }
  }
}
</script>

<style>
.flip-container {
  height: 70px;
  width: 80px;
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