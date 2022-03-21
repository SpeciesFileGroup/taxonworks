<template>
  <div>
    <p>Select</p>
    <ul class="context-menu no_bullets">
      <li
        v-for="item in typeLabels"
        :key="item">
        <label>
          <input
            type="radio"
            v-model="type"
            name="autocomplete_type"
            :value="item"
          >
          {{ item }}
        </label>
      </li>
    </ul>
    <div class="field margin-medium-top">
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
</template>
<script>

import Autocomplete from 'components/ui/Autocomplete.vue'

import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import ObservationTypes from '../../const/types.js'
import OtuPicker from 'components/otu/otu_picker/otu_picker'
import { 
  COLLECTION_OBJECT,
  OTU
} from 'constants/index.js'

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
      return this.type === OTU
    }
  },

  data () {
    return {
      typeLabels: [
        OTU,
        COLLECTION_OBJECT
      ],
      autocomplete_type: {
        [OTU]: '/otus/autocomplete',
        [COLLECTION_OBJECT]: '/collection_objects/autocomplete'
      },
      types: ObservationTypes.Row,
      type: OTU
    }
  },

  methods: {
    createRowItem (id) {
      const data = {
        observation_matrix_id: this.matrix.id,
        observation_object_id: id,
        observation_object_type: this.type,
        type: this.types[this.type]
      }

      this.$store.dispatch(ActionNames.CreateRowItem, data)
    }
  }
}
</script>
