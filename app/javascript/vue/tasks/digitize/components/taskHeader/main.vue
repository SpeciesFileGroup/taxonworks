<template>
  <div class="panel content separate-bottom">
    <div class="middle flex-separate">
      <div class="horizontal-left-content">
        <autocomplete
          url="/identifiers/autocomplete"
          placeholder="Search"
          label="label_html"
          param="term"
          :clear-after="true"
          @getItem="loadAssessionCode"
          :add-params="{
            'identifier_object_types[]': ['CollectionObject'],
          }"
          min="1"/>
        <span
          class="separate-left"
          v-if="identifier.id"
          v-html="identifier.object_tag"/>
      </div>
      <div class="horizontal-left-content">
      <tippy-component
        v-if="hasChanges"
        animation="scale"
        placement="bottom"
        size="small"
        arrow-size="small"
        :inertia="true"
        :arrow="true"
        :content="`<p>You have unsaved changes.</p>`">
        <template v-slot:trigger>
          <div
            class="medium-icon separate-right"
            data-icon="warning"/>
        </template>
      </tippy-component>
        <recent-component
          class="separate-right"
          @selected="loadCollectionObject($event)"/>
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
  import { TippyComponent } from 'vue-tippy'

  export default {
    components: {
      Autocomplete,
      RecentComponent,
      TippyComponent
    },
    computed: {
      identifier() {
        return this.$store.getters[GetterNames.GetIdentifier]
      },
      collectionObject() {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      collectingEvent() {
        return this.$store.getters[GetterNames.GetCollectionEvent]
      },
      settings: {
        get () {
          return this.$store.getters[GetterNames.GetSettings]
        },
        set (value) {
          this.$store.commit(MutationNames.SetSettings, value)
        }
      },
      hasChanges() {
        return this.settings.lastChange > this.settings.lastSave
      }
    },
    watch: {
      collectionObject: {
        handler(newVal) {
          this.settings.lastChange = Date.now()
        },
        deep: true
      },
      collectingEvent: {
        handler(newVal) {
          this.settings.lastChange = Date.now()
        },
        deep: true
      }
    },
    mounted() {
      window.addEventListener('scroll', () => {
        let element = this.$el
        if (element) {
          if (((window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0) > 164)) {
            element.classList.add('fixed-bar')
          } else {
            element.classList.remove('fixed-bar')
          }
        }
      })
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
        this.$store.dispatch(ActionNames.ResetWithDefault)
        this.$store.dispatch(ActionNames.LoadDigitalization, object.identifier_object_id)
      },
      loadCollectionObject(co) {
        this.resetStore()
        this.$store.dispatch(ActionNames.LoadContainer, co.global_id)
        this.$store.dispatch(ActionNames.LoadDigitalization, co.id)
      }
    }
  }
</script>
<style lang="scss" scoped>
  .fixed-bar {
    position: fixed;
    top:0px;
    width: calc(100%-52px);
    z-index:200;
  }
</style>