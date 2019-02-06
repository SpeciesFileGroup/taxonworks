<template>
  <div class="panel content separate-bottom">
    <div class="middle flex-separate">
      <div class="horizontal-left-content">
        <autocomplete
          url="/identifiers.json"
          placeholder="Search"
          label="object_tag"
          param="query_string"
          @getItem="loadAssessionCode"
          :add-params="{
            'identifier_object_types[]': ['CollectionObject', 'CollectingEvent'],
          }"
          min="1"/>
        <span
          class="separate-left"
          v-if="identifier.id"
          v-html="identifier.object_tag"/>
      </div>
      <div class="horizontal-left-content">
        <recent-component
          class="separate-right"
          @selected="loadCollectionObject($event.id)"/>
        <button 
          type="button"
          v-shortkey="[getMacKey(), 's']"
          @shortkey="saveDigitalization"
          class="button normal-input button-submit separate-right"
          @click="saveDigitalization">Save</button>  
        <button 
          type="button"
          v-shortkey="[getMacKey(), 'n']"
          @shortkey="saveAndNew"
          class="button normal-input button-submit separate-right"
          @click="saveAndNew">Save and new</button> 
        <div
          class="cursor-pointer"
          v-shortkey="[getMacKey(), 'r']"
          @shortkey="resetStore"
          @click="resetStore">
          <span data-icon="reset"/>
          <span>Reset</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import Autocomplete from '../../../../components/autocomplete.vue'
  import { MutationNames } from '../../store/mutations/mutations.js'
  import { ActionNames } from '../../store/actions/actions.js'
  import { GetterNames } from '../../store/getters/getters.js'
  import RecentComponent from './recent.vue'
  import GetMacKey from 'helpers/getMacKey.js'

  export default {
    components: {
      Autocomplete,
      RecentComponent
    },
    computed: {
      identifier() {
        return this.$store.getters[GetterNames.GetIdentifier]
      }
    },
    methods: {
      getMacKey: GetMacKey,
      saveDigitalization() {
        this.$store.dispatch(ActionNames.SaveDigitalization)
      },
      resetStore() {
        this.$store.commit(MutationNames.ResetStore)
      },
      saveAndNew() {
        this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
          let that = this
          setTimeout(() => {
            that.$store.dispatch(ActionNames.ResetWithDefault)
          }, 500)
        })
      },
      newDigitalization() {
        this.$store.dispatch(ActionNames.NewCollectionObject)
        this.$store.dispatch(ActionNames.NewIdentifier)
        this.$store.commit(MutationNames.NewTaxonDetermination)
        this.$store.commit(MutationNames.SetTaxonDeterminations, [])
      },
      saveCollectionObject() {
        this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
          this.$store.commit(MutationNames.SetTaxonDeterminations, [])
        })
      },
      loadAssessionCode(object) {
        this.$store.dispatch(ActionNames.LoadDigitalization, object.identifier_object_id)
      },
      loadCollectionObject(id) {
        this.resetStore()
        this.$store.dispatch(ActionNames.LoadDigitalization, id)
      }
    }
  }
</script>
