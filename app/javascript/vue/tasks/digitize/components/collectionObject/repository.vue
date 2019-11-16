<template>
  <div>
    <h2>Repository</h2>
    <fieldset class="fieldset">
      <legend>Repository</legend>
      <div class="horizontal-left-content middle separate-bottom">
        <smart-selector 
          name="repository"
          class="item separate-right"
          v-model="view"
          :add-option="['search']"
          :options="options"/>
        <default-repository
          class="separate-right"
          section="Repositories"
          @getId="repository = $event"
          @getLabel="repositorySelected = $event"
          type="Repository"/>
        <lock-component
          class="separate-left"
          v-model="locked.collection_object.repository_id"/>
      </div>
      <ul
        class="no_bullets"
        v-if="view != 'search'">
        <li
          v-for="(item, key) in lists[view]"
          :key="key">
          <label>
            <input
              type="radio"
              v-model="repository"
              :value="item.id">
            <span v-html="item.object_tag"/>
          </label>
        </li>
      </ul>
      <div v-show="view == 'search'">
        <autocomplete
          url="/repositories/autocomplete"
          label="label_html"
          param="term"
          placeholder="Search"
          ref="autocomplete"
          @getItem="setRepository($event.id, $event.label)"
          min="2"/>
      </div>
      <template v-if="repository">
        <div class="middle separate-top">
          <span data-icon="ok"/>
          <span class="separate-right"> {{ repositorySelected }}</span>
          <span
            class="circle-button button-default btn-undo"
            @click="repository = undefined"/>
        </div>
      </template>
    </fieldset>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import SmartSelector from 'components/switch'
import LockComponent from 'components/lock'
import DefaultRepository from 'components/getDefaultPin'
import { GetRepositorySmartSelector, GetRepository } from '../../request/resources.js'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import orderSmartSelector from '../../helpers/orderSmartSelector.js'
import selectFirstSmartOption from '../../helpers/selectFirstSmartOption'

export default {
  components: {
    Autocomplete,
    SmartSelector,
    LockComponent,
    DefaultRepository
  },
  computed: {
    locked: {
      get() {
        return this.$store.getters[GetterNames.GetLocked]
      },
      set(value) {
        this.$store.commit(MutationNames.SetLocked, value)
      }
    },
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    repository: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].repository_id
      },
      set(value) {
        return this.$store.commit(MutationNames.SetCollectionObjectRepositoryId, value)
      }
    }
  },
  watch: {
    repository(newVal, oldVal) {
      if(!newVal) {
        this.$refs.autocomplete.cleanInput()
      }
      else {
        let that = this
        GetRepository(newVal).then(response => {
          this.$refs.autocomplete.setLabel(response.name)
          this.setRepository(response.id, response.name)
        })
      }
    },
    collectionObject(newVal, oldVal) {
      if (!newVal.id || newVal.id == oldVal.id) return
      this.loadTabList()
    }
  },
  data() {
    return {
      view: 'search',
      options: [],
      lists: [],
      repositorySelected: undefined
    }
  },
  mounted() {
    this.loadTabList()
  },
  methods: {
    loadTabList() {
      GetRepositorySmartSelector().then(response => {
        let result = response
        this.options = orderSmartSelector(Object.keys(result))
        this.view = selectFirstSmartOption(response, this.options)
        this.lists = response
      })
    },
    setRepository(id, label) {
      this.repository = id
      this.repositorySelected = label
    }
  }
}
</script>
<style scoped>
  .fieldset {
    margin: 0px;
  }
</style>
