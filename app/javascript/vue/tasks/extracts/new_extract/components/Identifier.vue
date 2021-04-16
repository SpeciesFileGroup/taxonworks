<template>
  <div>
    <h2>Identifier</h2>
    <div class="flex-wrap-column middle align-start full_width">
      <template v-if="typeListSelected">
        <span class="capitalize">{{ typeListSelected }}</span>
        <button
          class="button button-default"
          @click="typeListSelected = undefined">
          Change
        </button>
        <select-type
          :list="typeList[typeListSelected]"
          v-model="typeSelected"/>
      </template>

      <ul
        v-else
        class="no_bullets">
        <li
          v-for="(item, key) in typeList"
          :key="key">
          <label class="capitalize">
            <input
              type="radio"
              v-model="typeListSelected"
              :value="key"
            >
            {{ key }}
          </label>
        </li>
      </ul>

      <template v-if="typeSelected">
        <namespace-component
          v-if="isTypeListLocal"
          v-model="namespace"/>
        <identifier-component
          class="margin-small-bottom"
          v-model="identifier"/>

        <button
          type="button"
          class="button button-submit normal-input"
          :disabled="isMissingData"
          @click="addIdentifier(); resetIdentifier()">
          Add
        </button>
      </template>
    </div>
    <display-list
      :list="identifiers"
      label="object_tag"
    />
  </div>
</template>

<script>

import { GetIdentifierTypes } from '../request/resources'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { MutationNames } from '../store/mutations/mutations'

import componentExtend from './mixins/componentExtend'
import SelectType from './Identifiers/SelectType'
import NamespaceComponent from './Identifiers/Namespace'
import IdentifierComponent from './Identifiers/Identifier'
import DisplayList from 'components/displayList'

export default {
  mixins: [componentExtend],

  components: {
    DisplayList,
    SelectType,
    NamespaceComponent,
    IdentifierComponent
  },

  data () {
    return {
      namespace: undefined,
      identifier: undefined,
      typeList: undefined,
      typeListSelected: undefined,
      typeSelected: undefined
    }
  },

  computed: {
    identifiers: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifiers]
      },
      set (value) {
        this.$store.commit(MutationNames.SetIdentifiers, value)
      }
    },

    extractId () {
      return this.$store.getters[GetterNames.GetExtract].id
    },

    isTypeListLocal () {
      return this.typeListSelected === 'local'
    },

    isMissingData () {
      return (!this.namespace && this.typeListSelected !== 'unknown') || !this.identifier
    }
  },

  created () {
    GetIdentifierTypes().then(({ body }) => {
      const list = body
      const keys = Object.keys(body)
      keys.forEach(key => {
        const itemList = list[key]
        itemList.common = Object.fromEntries(itemList.common.map(item => ([item, Object.entries(itemList.all).find(([key, value]) => key === item)[1]])))
      })
      this.typeList = body
    })
  },

  watch: {
    existingIdentifier (newVal) {
      this.settings.saveIdentifier = !newVal
    },

    extractId (newVal) {
      if (newVal) {
        this.$store.dispatch(ActionNames.LoadIdentifiers)
      }
    }
  },

  methods: {
    addIdentifier () {
      const data = {
        namespace_id: this.namespace?.id,
        object_tag: [this.namespace?.name || '', this.identifier].filter(item => item).join(' '),
        identifier: this.identifier,
        type: this.typeSelected
      }

      this.identifiers.push(data)
    },

    resetIdentifier () {
      this.namespace = undefined
      this.identifier = undefined
    }
  }
}
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
