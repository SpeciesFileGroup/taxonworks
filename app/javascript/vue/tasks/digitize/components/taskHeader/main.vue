<template>
  <nav-bar style="z-index: 1001">
    <div
      id="comprehensive-navbar"
      v-hotkey="shortcuts"
      class="flex-separate">
      <div class="horizontal-left-content">
        <autocomplete
          class="separate-right"
          url="/collection_objects/autocomplete"
          placeholder="Search"
          label="label_html"
          param="term"
          :clear-after="true"
          @getItem="loadAssessionCode($event.id)"
          min="1"/>
        <soft-validation
          v-if="collectionObject.id"
          class="margin-small-left margin-small-right"/>
        <a
          class="separate-left"
          v-if="collectionObject.id"
          :href="`/tasks/collection_objects/browse?collection_object_id=${collectionObject.id}`"
          v-html="collectionObject.object_tag"/>
        <span v-else>New record</span>
      </div>
      <div class="horizontal-left-content">
        <div
          class="margin-medium-right horizontal-left-content"
          v-if="collectionObject.id">
          <ul class="context-menu no_bullets">
            <li>
              <span
                v-if="navigation.previous"
                @click="loadAssessionCode(navigation.previous)"
                class="link cursor-pointer horizontal-right-content">‹ Id</span>
              <span
                v-else
                class="horizontal-right-content">‹ Id </span>
              <span
                v-if="navigation.previousIdentifier"
                @click="loadAssessionCode(navigation.previousIdentifier)"
                class="link cursor-pointer horizontal-right-content">‹ Identifier</span>
              <span v-else>‹ Identifier</span>
            </li>
            <li>
              <span
                v-if="navigation.next"
                @click="loadAssessionCode(navigation.next)"
                class="link cursor-pointer horizontal-left-content">Id ›</span>
              <span
                v-else
                class="horizontal-left-content">Id ›</span>
              <span
                v-if="navigation.nextIdentifier"
                @click="loadAssessionCode(navigation.nextIdentifier)"
                class="link cursor-pointer horizontal-left-content">Identifier ›</span>
              <span v-else>Identifier ›</span>
            </li>
          </ul>
        </div>
        <tippy
          v-if="hasChanges"
          animation="scale"
          placement="bottom"
          size="small"
          inertia
          arrow
          :content="`<p>You have unsaved changes.</p>`">
          <div
            class="medium-icon separate-right"
            data-icon="warning"/>
        </tippy>
        <recent-component
          class="separate-right"
          @selected="loadCollectionObject($event)"/>
        <button 
          type="button"
          class="button normal-input button-submit separate-right"
          @click="saveDigitalization">Save</button>  
        <button 
          type="button"
          class="button normal-input button-submit separate-right"
          @click="saveAndNew">Save and new</button> 
        <div
          class="cursor-pointer"
          @click="resetStore">
          <span data-icon="reset"/>
          <span>Reset</span>
        </div>
      </div>
    </div>
  </nav-bar>
</template>

<script>

import { Tippy } from 'vue-tippy'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import { GetterNames } from '../../store/getters/getters.js'
import RecentComponent from './recent.vue'
import platformKey from 'helpers/getMacKey.js'
import Autocomplete from 'components/ui/Autocomplete.vue'
import NavBar from 'components/layout/NavBar'
import AjaxCall from 'helpers/ajaxCall'
import SoftValidation from './softValidation'

export default {
  components: {
    Autocomplete,
    RecentComponent,
    Tippy,
    NavBar,
    SoftValidation
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
    },
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+s`] = this.saveDigitalization
      keys[`${platformKey()}+n`] = this.saveAndNew
      keys[`${platformKey()}+r`] = this.resetStore

      return keys
    },
  },
  data () {
    return {
      navigation: {
        next: undefined,
        previous: undefined
      },
      loadingNavigation: false
    }
  },
  watch: {
    collectionObject: {
      handler(newVal, oldVal) {
        this.settings.lastChange = Date.now()
        if (newVal.id && oldVal.id != newVal.id) {
          if (!this.loadingNavigation) {
            this.loadingNavigation = true
            AjaxCall('get', `/metadata/object_navigation/${encodeURIComponent(newVal.global_id)}`).then(({ headers }) => {
              this.navigation.next = headers['navigation-next']
              this.navigation.nextIdentifier = headers['navigation-next-by-identifier']
              this.navigation.previous = headers['navigation-previous']
              this.navigation.previousIdentifier = headers['navigation-previous-by-identifier']
              this.loadingNavigation = false
            })
          }
        }
      },
      deep: true
    },
    collectingEvent: {
      handler (newVal) {
        this.settings.lastChange = Date.now()
      },
      deep: true
    }
  },
  methods: {
    saveDigitalization () {
      this.$store.dispatch(ActionNames.SaveDigitalization)
    },

    resetStore () {
      this.$store.commit(MutationNames.ResetStore)
    },

    saveAndNew () {
      this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
        setTimeout(() => {
          this.$store.dispatch(ActionNames.ResetWithDefault)
        }, 500)
      })
    },

    newDigitalization () {
      this.$store.dispatch(ActionNames.NewCollectionObject)
      this.$store.dispatch(ActionNames.NewIdentifier)
      this.$store.commit(MutationNames.NewTaxonDetermination)
      this.$store.commit(MutationNames.SetTaxonDeterminations, [])
    },

    saveCollectionObject () {
      this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
        this.$store.commit(MutationNames.SetTaxonDeterminations, [])
      })
    },

    loadAssessionCode (id) {
      this.$store.dispatch(ActionNames.ResetWithDefault)
      this.$store.dispatch(ActionNames.LoadDigitalization, id)
    },

    loadCollectionObject (co) {
      this.resetStore()
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
