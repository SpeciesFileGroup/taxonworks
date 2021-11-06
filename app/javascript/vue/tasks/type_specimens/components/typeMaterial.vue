<template>
  <div>
    <div class="panel type-specimen-box separate-bottom">
      <spinner
        v-if="!(protonymId && type)"
        :show-spinner="false"
        :show-legend="false"
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
          <switch-component
            v-model="view"
            :options="tabOptions"
          />
        </div>
        <div class="flex-separate">
          <div>
            <collection-object
              v-if="view === TAB.new || view === TAB.edit"
            />

            <div
              v-if="view == 'existing'"
              class="field">
              <label>Collection object</label>
              <autocomplete
                class="types_field"
                url="/collection_objects/autocomplete"
                param="term"
                label="label_html"
                placeholder="Search..."
                @getItem="setCollectionObject"
                display="label"
                min="2"
              />
            </div>
          </div>
          <div class="margin-medium-left">
            <div
              class="field"
              v-if="protonymId"
            >
              <label>Depiction</label>
              <depictions-section />
              To add a catalog number use the radial annotator above after save.
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
import ActionNames from '../store/actions/actionNames'

import Autocomplete from 'components/ui/Autocomplete.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import Spinner from 'components/spinner.vue'
import Expand from 'components/expand.vue'
import CollectionObject from './collectionObject.vue'
import DepictionsSection from './depictions.vue'
import SwitchComponent from 'components/switch.vue'

import { RouteNames } from 'routes/routes'

const TAB = {
  edit: 'edit',
  new: 'new',
  existing: 'existing'
}

export default {
  components: {
    DepictionsSection,
    CollectionObject,
    Autocomplete,
    Expand,
    RadialAnnotator,
    Spinner,
    SwitchComponent
  },

  computed: {
    typeMaterial () {
      return this.$store.getters[GetterNames.GetTypeMaterial]
    },

    total () {
      return this.$store.getters[GetterNames.GetCollectionObjectTotal]
    },

    protonymId () {
      return this.$store.getters[GetterNames.GetProtonymId]
    },

    type () {
      return this.$store.getters[GetterNames.GetType]
    },

    biologicalId () {
      return this.$store.getters[GetterNames.GetBiologicalId]
    }
  },

  data () {
    return {
      tabOptions: [TAB.new, TAB.existing],
      displayBody: true,
      view: TAB.new,
      TAB
    }
  },

  watch: {
    typeMaterial (newVal) {
      if (newVal.id) {
        this.view = TAB.edit
        this.tabOptions = [TAB.edit, TAB.existing]
      } else {
        this.tabOptions = [TAB.new, TAB.existing]
      }
    }
  },

  methods: {
    getDigitizeRoute () {
      return `${RouteNames.DigitizeTask}?collection_object_id=${this.biologicalId}`
    },

    createTypeMaterial () {
      this.$store.dispatch(ActionNames.CreateTypeMaterial)
    },

    saveTypeMaterial () {
      if (this.typeMaterial.id) {
        this.updateTypeMaterial()
      } else {
        this.createTypeMaterial()
      }
    },

    updateTypeMaterial () {
      const typeMaterial = this.$store.getters[GetterNames.GetTypeMaterial]

      this.$store.dispatch(ActionNames.UpdateTypeSpecimen, typeMaterial)
    },

    setCollectionObject (collectionObject) {
      this.$store.dispatch(ActionNames.SetTypeMaterialCO, collectionObject)
    }
  }
}
</script>
