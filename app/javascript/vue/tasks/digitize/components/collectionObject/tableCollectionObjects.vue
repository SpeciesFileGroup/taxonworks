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
        class="list-complete-item highlight">
        <td>
          <input
            v-if="!collectionObject.id"
            :data-index="0"
            type="number"
            class="total-size .co-total-count"
            min="1"
            v-model="collectionObject.total">
          <input
            v-else
            :data-index="0"
            class="total-size co-total-count"
            type="number"
            @change="updateCO(collectionObject)"
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
        <td class="horizontal-right-content">
          <template v-if="collectionObject.id">
            <accession-metadata :collection-object="collectionObject"/>
            <radial-annotator :global-id="collectionObject.global_id"/>
            <button
              type="button"
              class="button circle-button btn-edit"
              @click="setCO(collectionObject)">Select</button>
            <pin-component
              type="CollectionObject"
              :object-id="collectionObject.id"/>
            <button
              type="button"
              class="button circle-button btn-delete"
              @click="removeCO(collectionObject.id)"/>
          </template>
        </td>
      </tr>
      <template
        v-for="(item, index) in collectionObjects"
        :key="item.id">
        <tr
          class="list-complete-item"
          :class="{ 'highlight': isSelected(item) }"
          v-if="collectionObject.id != item.id">
          <td>
            <input
              :data-index="index"
              class="total-size co-total-count"
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
            <accession-metadata :collection-object="item"/>
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
      </template>
    </tbody>
  </table>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { ControlledVocabularyTerm, Tag } from 'routes/endpoints'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import Bioclassification from './bioclassification.vue'
import LockComponent from 'components/ui/VLock/index.vue'
import AccessionMetadata from './accession'

export default {
  components: {
    LockComponent,
    RadialAnnotator,
    PinComponent,
    Bioclassification,
    AccessionMetadata
  },
  computed: {
    locked: {
      get () {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set (value) {
        this.$store.commit([MutationNames.SetLocked, value])
      }
    },
    collectionObjects () {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    }
  },

  data() {
    return {
      biocurationsGroups: [],
      biocutarionsType: []
    }
  },

  created () {
    ControlledVocabularyTerm.where({ type: ['BiocurationGroup'] }).then(response => {
      this.biocurationsGroups = response.body
      ControlledVocabularyTerm.where({ type: ['BiocurationClass'] }).then(response => {
        this.biocutarionsType = response.body
        this.splitGroups()
      })
    })
  },

  methods: {
    setCO(co) {
      this.$store.dispatch(ActionNames.LoadDigitalization, co.id)
    },
    removeCO(id) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$store.dispatch(ActionNames.RemoveCollectionObject, id)
      }
    },
    isSelected (item) {
      return this.collectionObject.id === item.id
    },
    updateCO(co) {
      this.$store.dispatch(ActionNames.SaveCollectionObject, co)
    },
    splitGroups () {
      this.biocurationsGroups.forEach((item, index) => {
        Tag.where({ keyword_id: item.id }).then(response => {
          const tmpArray = []
          response.body.forEach(item => {
            this.biocutarionsType.forEach(itemClass => {
              if (itemClass.id === item.tag_object_id) {
                tmpArray.push(itemClass)
                return
              }
            })
          })
          this.biocurationsGroups[index]['list'] = tmpArray
        })
      })
    },
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
