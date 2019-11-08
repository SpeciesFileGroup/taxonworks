<template>
  <table class="vue-table">
    <thead>
      <tr>
        <th>Total</th>
        <th class="lock-biocuration"></th>
        <th>Biocurations</th>
        <th></th>
      </tr>
    </thead>
    <tbody class="list-complete">
      <tr
        class="list-complete-item highlight"
        v-show="!collectionObject.id">
        <td>
          <input
            type="number"
            class="total-size"
            min="1"
            v-model="collectionObject.total">
        </td>
        <td class="lock-biocuration">
          <lock-component v-model="locked.biocuration"/>
        </td>
        <td>
          <bioclassification 
            :biocurations-groups="biocurationsGroups"
            :biocutarions-type="biocutarionsType"
            :biological-id="collectionObject.id"/>          
        </td>
        <td></td>
      </tr>
      <tr
        v-for="item in collectionObjects"
        :key="item.id"
        class="list-complete-item"
        :class="{ 'highlight': isSelected(item) }">
        <td>
          <input
            class="total-size"
            type="number"
            @change="updateCO(item)"
            v-model="item.total">
        </td>
        <td></td>
        <td>
          <bioclassification 
            :biological-id="item.id"
            :biocurations-groups="biocurationsGroups"
            :biocutarions-type="biocutarionsType"/>
        </td>
        <td class="horizontal-right-content">
          <radial-annotator :global-id="item.global_id"/>
          <button
            type="button"
            class="button circle-button btn-edit"
            @click="setCO(item)">Select</button>
          <pin-component
            type="CollectionObject"
            :object-id="item.id"/>
          <button
            type="button"
            class="button circle-button btn-delete"
            @click="removeCO(item.id)"/>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import RadialAnnotator from '../../../../components/annotator/annotator.vue'
import PinComponent from '../../../../components/pin.vue'
import Bioclassification from './bioclassification.vue'
import LockComponent from 'components/lock'

import { GetBiocurationsTypes, GetBiocurationsGroupTypes } from '../../request/resources.js'

export default {
  components: {
    LockComponent,
    RadialAnnotator,
    PinComponent,
    Bioclassification
  },
  computed: {
    locked: {
      get() {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set(value) {
        this.$store.commit([MutationNames.SetLocked, value])
      }
    },
    collectionObjects() {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },
    collectionObject: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObject)
      }
    }
  },
  data() {
    return {
      biocurationsGroups: [],
      biocutarionsType: []
    }
  },
  mounted: function () {
    GetBiocurationsGroupTypes().then(response => {
      this.biocurationsGroups = response
      GetBiocurationsTypes().then(response => {
        this.biocutarionsType = response
      })
    })
  },
  methods: {
    setCO(co) {
      this.$store.dispatch(ActionNames.LoadDigitalization, co.id)
    },
    removeCO(id) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$store.dispatch(ActionNames.RemoveCollectionObject, id)
      }
    },
    isSelected(item) {
      return this.collectionObject.id == item.id
    },
    updateCO(co) {
      this.$store.dispatch(ActionNames.SaveCollectionObject, co)
    }
  }
}
</script>
<style scoped>
  .highlight {
    background-color: #E3E8E3;
  }
  .vue-table {
    min-width: 100%;
  }
  .lock-biocuration {
    width: 30px;
  }
  .total-size {
    width: 100px;
  }
</style>

