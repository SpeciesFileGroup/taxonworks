<template>
  <div>
    <div class="flex-separate middle">
      <h1>New extract</h1>
      <label>
        <input
          type="checkbox"
          v-model="settings.sortable">
        Reorder fields
      </label>
    </div>
    <navbar-component
      @onSave="saveExtract"
      @onReset="resetState"
    />
    <div class="flexbox">
      <div class="item">
        <draggable
          class="full_width"
          v-model="componentsOrder"
          :disabled="!settings.sortable"
          :item-key="item => item"
          @end="updatePreferences"
        >
          <template #item="{ element }">
            <component
              class="margin-medium-bottom"
              :is="element"/>
          </template>
        </draggable>
      </div>
      <div class="item margin-medium-left">
        <recent-component
          @onLoad="loadExtract"/>
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

import NavbarComponent from './components/Navbar.vue'
import Draggable from 'vuedraggable'
import SoftValidation from './components/SoftValidation.vue'
import RecentComponent from './components/Recent'

export default {
  components: {
    Draggable,
    NavbarComponent,
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

    extract () {
      return this.$store.getters[GetterNames.GetExtract]
    }
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
    },
    extract: {
      handler (newVal) {
        this.$store.commit(MutationNames.SetLastChange, Date.now())
      },
      deep: true
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const extractId = urlParams.get('extract_id')

    if (/^\d+$/.test(extractId)) {
      this.loadExtract({ id: extractId })
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
      const promise = []

      dispatch(ActionNames.SaveExtract).then(() => {
        TW.workbench.alert.create('Extract was saved successfully', 'notice')
        promise.push(dispatch(ActionNames.SaveOriginRelationship))
        promise.push(dispatch(ActionNames.SaveIdentifiers))
        promise.push(dispatch(ActionNames.SaveProtocols))
      })

      Promise.all(promise).then(() => {
        this.$nextTick(() => {
          this.$store.commit(MutationNames.SetLastChange, 0)
        })
      })
    },

    resetState () {
      this.$store.dispatch(ActionNames.ResetState)
      this.$nextTick(() => {
        this.$store.commit(MutationNames.SetLastChange, 0)
      })
    },

    removeRecent (extract) {
      this.$store.dispatch(ActionNames.RemoveExtract, extract)
    },

    loadExtract ({ id }) {
      this.$store.dispatch(ActionNames.LoadExtract, id).then(() => {
        this.$store.commit(MutationNames.SetLastChange, 0)
      })
    }
  }
}
</script>
