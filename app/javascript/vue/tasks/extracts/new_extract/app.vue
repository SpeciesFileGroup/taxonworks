<template>
  <div>
    <div>
      <h1>New extract</h1>
      <label>
        <input
          type="checkbox"
          v-model="settings.sortable">
        Sort fields
      </label>
    </div>
    <navbar-component>
      <div class="flex-separate middle">
        New
        <div class="horizontal-right-content">
          <button
            type="button"
            class="button normal-input button-submit margin-small-right">
            Save
          </button>
          <button
            type="button"
            class="button normal-input button-default margin-small-right">
            Recent
          </button>
          <button
            type="button"
            class="button normal-input button-default">
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
      <div class="item">
        <soft-validation/>
      </div>
    </div>
  </div>
</template>

<script>

import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'
import { VueComponent } from './const/components'

import NavbarComponent from 'components/navBar'
import OriginComponent from './components/Origin'
import MadeComponent from './components/Made'
import RepositoryComponent from './components/Repository'
import Draggable from 'vuedraggable'
import SoftValidation from './components/SoftValidation.vue'

export default {
  components: {
    Draggable,
    NavbarComponent,
    OriginComponent,
    MadeComponent,
    RepositoryComponent,
    SoftValidation,
    ...VueComponent
  },

  data () {
    return {
      componentsOrder: Object.keys(VueComponent)
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
    }
  },

  created () {
    this.$store.dispatch(ActionNames.LoadProjectPreferences)
    this.$store.dispatch(ActionNames.LoadUserPreferences)
  },

  methods: {
    updatePreferences () {},
    saveExtract () {
      this.$store.dispatch(ActionNames.SaveExtract)
    }
  }
}
</script>
