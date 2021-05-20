<template>
  <div>
    <div class="panel type-specimen-box separate-bottom">
      <spinner
        :show-spinner="false"
        :show-legend="false"
        v-if="!(protonymId && type)" 
      />
      <div class="header flex-separate middle">
        <h3>Collection object</h3>
        <div class="horizontal-left-content middle">
          <a
            v-if="biologicalId"
            target="blank"
            :href="getDigitizeRoute()"
          >Expanded edit
          </a>
          <radial-annotator
            v-if="typeMaterial.id"
            :global-id="typeMaterial.collection_object.global_id"
          />
          <expand v-model="displayBody" />
        </div>
      </div>
      <div
        class="body"
        v-if="displayBody"
      >
        <div class="switch-radio field">
          <template v-for="(item, index) in tabOptions">
            <input
              v-model="view"
              :value="item"
              :id="`switch-picker-${index}`"
              name="switch-picker-options"
              type="radio"
              class="normal-input button-active"
            >
            <label
              :for="`switch-picker-${index}`"
              class="capitalize"
            >{{ item }}</label>
          </template>
        </div>
        <div class="flex-separate">
          <div>
            <collection-object
              v-if="view == 'new'"
            />

            <collection-object
              v-if="view == 'edit'"
            />

            <template
              v-if="view == 'existing'"
            >
              <div class="field">
                <label>Collection object</label>
                <autocomplete
                  class="types_field"
                  url="/collection_objects/autocomplete"
                  param="term"
                  label="label_html"
                  :send-label="getOwnPropertyNested(typeMaterial, 'collection_object', 'object_tag')"
                  @getItem="biologicalId = $event.id; (typeMaterial.id ? updateTypeMaterial() : createTypeMaterial())"
                  display="label"
                  min="2" 
                />
              </div>
            </template>
          </div>
          <div class="margin-medium-left">
            <div
              class="field"
              v-if="protonymId"
            >
              <label>Depiction</label>
              <depictions-section />
              <catalog-number/>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="field separate-top">
      <button
        @click="saveTypeMaterial"
        :disabled="total < 1 || !(protonymId && type)"
        type="button"
        class="button normal-input button-submit"
      >
        {{ (typeMaterial.id ? 'Update' : 'Create') }}
      </button>
    </div>  
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import ActionNames from '../store/actions/actionNames'

import Autocomplete from 'components/ui/Autocomplete.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import Spinner from 'components/spinner.vue'
import Expand from './expand.vue'
import CollectionObject from './collectionObject.vue'
import DepictionsSection from './depictions.vue'
import CatalogNumber from './catalogNumber'

import { RouteNames } from 'routes/routes'

export default {
  components: {
    DepictionsSection,
    CollectionObject,
    Autocomplete,
    Expand,
    RadialAnnotator,
    Spinner,
    CatalogNumber
  },
  computed: {
    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },
    getCollectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    total() {
      return this.$store.getters[GetterNames.GetCollectionObjectTotal]
    },
    protonymId: {
      get () {
        return this.$store.getters[GetterNames.GetProtonymId]
      },
      set (value) {
        this.$store.commit(MutationNames.SetProtonymId, value)
      }
    },
    type: {
      get () {
        return this.$store.getters[GetterNames.GetType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetType, value)
      }
    },
    biologicalId: {
      get () {
        return this.$store.getters[GetterNames.GetBiologicalId]
      },
      set (value) {
        this.$store.commit(MutationNames.SetBiologicalId, value)
      }
    },
    view: {
      get () {
        return this.$store.getters[GetterNames.GetSettings].materialTab
      },
      set (value) {
        this.$store.commit(MutationNames.SetMaterialTab, value)
      }
    }
  },
  data: function () {
    return {
      tabOptions: ['new', 'existing'],
      displayBody: true,
      roles_attribute: []
    }
  },
  watch: {
    typeMaterial (newVal) {
      if (newVal.id) {
        this.view = 'edit'
        this.tabOptions = ['edit', 'existing']
      } else {
        this.tabOptions = ['new', 'existing']
      }
    }
  },
  methods: {
    getDigitizeRoute() {
      return `${RouteNames.DigitizeTask}?collection_object_id=${this.biologicalId}`
    },
    createTypeMaterial () {
      this.$store.dispatch(ActionNames.CreateTypeMaterial)
    },
    saveTypeMaterial() {
      if(this.view == 'edit') {
        this.updateTypeMaterial()
      }
      else {
        this.createTypeMaterial()
      }
    },
    updateTypeMaterial () {
      let typeMaterial = this.$store.getters[GetterNames.GetTypeMaterial]
      this.$store.dispatch(ActionNames.UpdateTypeSpecimen, {type_material: typeMaterial})
    },
    updateCollectionObject () {
      let typeMaterial = this.$store.getters[GetterNames.GetTypeMaterial]
      this.$store.dispatch(ActionNames.UpdateCollectionObject, {type_material: typeMaterial})
    },
    getOwnPropertyNested (obj) {
      let args = Array.prototype.slice.call(arguments, 1)

      for (let i = 0; i < args.length; i++) {
        if (!obj || !obj.hasOwnProperty(args[i])) {
          return undefined
        }
        obj = obj[args[i]]
      }
      return obj
    }
  }
}
</script>
<style scoped>
    .switch-radio label {
        width: 100px;
    }
</style>
