<template>
  <div>
    <p>Select</p>
    <div class="flex-wrap">
      <template
        v-for="item, key in autocomplete_type"
        class="field">
        <label class="label-flex">
        <input
          type="radio"
          v-model="type"
          name="autocomplete_type"
          :value="key"
          checked>
          {{ key }}
        </label>
      </template>
      <div class="field">
        <autocomplete
          min="2"
          :placeholder="`Select a ${type}`"
          label="label"
          @getItem="objectId = $event.id"
          :url="autocomplete_type[type]"
          param="term"/>
      </div>
    </div>
    <button
      class="normal-input button button-submit"
      type="button"
      @click="createRowItem">Create
    </button>
  </div>
</template>
<script>

import Autocomplete from '../../../../components/autocomplete.vue'

import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    Autocomplete
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    }
  },
  data() {
    return {
      autocomplete_type: {
        Otu: '/otus/autocomplete',
        CollectionObject: '/collection_objects/autocomplete',
      },
      types: {
        Otu: 'ObservationMatrixRowItem::SingleOtu',
        CollectionObject: 'ObservationMatrixRowItem::SingleCollectionObject',
      },
      type: 'Otu',
      objectId: undefined,
    }
  },
  methods: {
    createRowItem() {
      let data = {
        observation_matrix_id: this.matrix.id,
        type: this.types[this.type]
      }

      data[(this.type === 'Otu' ? 'otu_id' : 'collection_object_id')] = this.objectId

      this.$store.dispatch(ActionNames.CreateRowItem, data)
    }
  }
}
</script>