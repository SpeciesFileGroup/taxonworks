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
        <otu-picker
          v-if="isOtuType"
          clear-after
          @getItem="createRowItem($event.id)"/>
        <autocomplete
          v-else
          min="2"
          :placeholder="`Select a ${type}`"
          label="label_html"
          :clear-after="true"
          @getItem="createRowItem($event.id)"
          :url="autocomplete_type[type]"
          param="term"/>
      </div>
    </div>
  </div>
</template>
<script>

import Autocomplete from 'components/ui/Autocomplete.vue'

import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import ObservationTypes from '../../const/types.js'
import OtuPicker from 'components/otu/otu_picker/otu_picker'

export default {
  components: {
    Autocomplete,
    OtuPicker
  },

  computed: {
    matrix () {
      return this.$store.getters[GetterNames.GetMatrix]
    },

    isOtuType () {
      return this.type === 'Otu'
    }
  },

  data () {
    return {
      autocomplete_type: {
        Otu: '/otus/autocomplete',
        CollectionObject: '/collection_objects/autocomplete',
      },
      types: ObservationTypes.Row,
      type: 'Otu'
    }
  },

  methods: {
    createRowItem (id) {
      const data = {
        observation_matrix_id: this.matrix.id,
        type: this.types[this.type]
      }

      data[(this.type === 'Otu' ? 'otu_id' : 'collection_object_id')] = id

      this.$store.dispatch(ActionNames.CreateRowItem, data)
    }
  }
}
</script>
