<template>
  <modal-component
    @close="$emit('close', true)">
    <template #header>
      <h3>New predicate</h3>
    </template>
    <template #body>
      <div class="field">
        <label>Name</label>
        <input
          type="text"
          v-model="predicate.name"
        >
      </div>
      <div class="field">
        <label>Definition</label>
        <textarea
          type="text"
          v-model="predicate.definition"
        />
      </div>
      <div class="field">
        <label>Uri</label>
        <textarea
          type="text"
          v-model="predicate.uri"
        />
      </div>
      <div class="field">
        <label>Uri relation</label>
        <select v-model="predicate.uri_relation">
          <option
            v-for="item in uriRelationList"
            :value="item"
            :key="item"
          >
            {{ item }}
          </option>
        </select>
      </div>
      <button
        type="button"
        :disabled="!validate"
        class="button normal-input button-submit"
        @click="sendPredicate(predicate)"
      >
        Create
      </button>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal'

export default {
  components: {
    ModalComponent
  },

  computed: {
    validate () {
      return this.predicate.name && 
        this.predicate.name.length &&
        this.predicate.definition &&
        this.predicate.definition.length >= this.minDefinitionLength
    }
  },

  data () {
    return {
      minDefinitionLength: 20,
      uriRelationList: [
        'skos:broadMatch', 
        'skos:narrowMatch', 
        'skos:relatedMatch',
        'skos:closeMatch',
        'skos:exactMatch'
      ],
      predicate: this.newPredicate()
    }
  },

  methods: {
    newPredicate() {
      return {
        type: 'Predicate',
        name: undefined,
        definition: undefined,
        uri: undefined,
        uri_relation: undefined
      }
    },

    sendPredicate(predicate) {
      this.$emit('onNew', predicate)
      this.$emit('close', true)
    }
  }
}
</script>
<style scoped>
  label {
    display: block;
  }
  input, textarea {
    width: 100%;
  }
</style>
