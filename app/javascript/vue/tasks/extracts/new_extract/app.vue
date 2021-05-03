<template>
  <div>
    <div class="flex-separate middle">
      <h1>New extract</h1>
      <label>
        <input
          type="checkbox"
          v-model="settings.sortable">
        Sortable fields
      </label>
    </div>
    <navbar-component>
      <div class="flex-separate middle">
        <span
          v-if="extract.id"
          v-html="extract.object_tag"/>
        <span v-else>
          New
        </span>
        <div class="horizontal-right-content">
          <button
            type="button"
            class="button normal-input button-submit margin-small-right"
            v-shortkey="[OSKey, 's']"
            @shortkey="saveExtract"
            @click="saveExtract">
            Save
          </button>
          <button
            type="button"
            class="button normal-input button-default margin-small-right">
            Recent
          </button>
          <button
            type="button"
            class="button normal-input button-default"
            v-shortkey="[OSKey, 'n']"
            @shortkey="resetState"
            @click="resetState">
            New
          </button>
        </div>
      </div>
    </navbar-component>
    <div class="flexbox">
      <div class="item">
        <draggable
          class="full_width"
          v-model="componentsOrder"
          @end="updatePreferences"
          :disabled="!settings.sortable">
          <component
            class="panel content margin-medium-bottom"
            v-for="componentName in componentsOrder"
            :key="componentName"
            :is="componentName"/>
        </draggable>
      </div>
      <div class="item margin-medium-left">
        <recent-component />
        <soft-validation />
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'
import { VueComponent } from './const/components'
import { User } from 'routes/endpoints'

import NavbarComponent from 'components/navBar'
import MadeComponent from './components/Made'
import RepositoryComponent from './components/Repository'
import Draggable from 'vuedraggable'
import SoftValidation from './components/SoftValidation.vue'
import RecentComponent from './components/Recent'
import OSKey from 'helpers/getMacKey.js'

export default {
  components: {
    Draggable,
    NavbarComponent,
    MadeComponent,
    RepositoryComponent,
    SoftValidation,
    RecentComponent,
    ...VueComponent
  },

  data () {
    return {
      componentsOrder: Object.keys(VueComponent),
      keyStorage: 'tasks::extract::componentsOrder'
    }
  },

  computed: {
    extract () {
      return this.$store.getters[GetterNames.GetExtract]
    },

    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },

    preferences: {
      get () {
        return this.$store.getters[GetterNames.GetUserPreferences]
      },

      set (value) {
        this.$store.commit(MutationNames.SetUserPreferences, value)
      }
    },

    OSKey
  },

  watch: {
    preferences: {
      handler () {
        const newOrder = this.preferences.layout[this.keyStorage]

        if (this.componentsOrder.every(componentName => newOrder?.includes(componentName))) {
          this.componentsOrder = newOrder
        }
      },
      deep: true
    }
  },

  mounted () {
    const urlParams = new URLSearchParams(window.location.search)
    const extractId = urlParams.get('extract_id')

    if (/^\d+$/.test(extractId)) {
      this.$store.dispatch(ActionNames.LoadExtract, extractId)
    }

    this.$store.dispatch(ActionNames.LoadProjectPreferences)
    this.$store.dispatch(ActionNames.LoadUserPreferences)
  },

  methods: {
    updatePreferences () {
      User.update(this.preferences.id, { user: { layout: { [this.keyStorage]: this.componentsOrder } } }).then(response => {
        this.preferences = response.body.preferences
      })
    },

    saveExtract () {
      const { dispatch } = this.$store

      dispatch(ActionNames.SaveExtract).then(() => {
        TW.workbench.alert.create('Extract was saved successfully', 'notice')
        dispatch(ActionNames.SaveOriginRelationship)
        dispatch(ActionNames.SaveIdentifiers)
        dispatch(ActionNames.SaveProtocols)
      })
    },

    resetState () {
      this.$store.dispatch(ActionNames.ResetState)
    }
  }
}
</script>
