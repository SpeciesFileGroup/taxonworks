<template>
  <block-layout>
    <h3 slot="header">Identifier</h3>
    <div
      slot="body"
      class="full_width">
      <template v-if="typeListSelected">
        <div class="horizontal-left-content middle">
          <span class="capitalize">{{ typeListSelected }}</span>
          <tippy-component
            animation="scale"
            placement="bottom"
            size="small"
            inertia
            arrow
            content="Change">
            <template slot="trigger">
              <button
                class="button button-circle button-default btn-undo"
                @click="typeListSelected = undefined"/>
            </template>
          </tippy-component>
        </div>
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
      </template>

      <div class="horizontal-left-content margin-small-top">
        <button
          type="button"
          class="button button-submit normal-input"
          :disabled="isMissingData"
          @click="addIdentifier(); resetIdentifier()">
          Add
        </button>
        <lock-component
          class="margin-small-left"
          v-model="settings.lock.identifiers"/>
      </div>
    </div>
    <display-list
      :list="identifiers"
      label="object_tag"
      @deleteIndex="removeIdentifier"
    />
  </block-layout>
</template>

<script>

import { Identifier } from 'routes/endpoints'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { TippyComponent } from 'vue-tippy'

import componentExtend from './mixins/componentExtend'
import SelectType from './Identifiers/SelectType'
import NamespaceComponent from './Identifiers/Namespace'
import IdentifierComponent from './Identifiers/Identifier'
import DisplayList from 'components/displayList'
import LockComponent from 'components/lock'
import BlockLayout from 'components/blockLayout.vue'

export default {
  mixins: [componentExtend],

  components: {
    DisplayList,
    SelectType,
    NamespaceComponent,
    IdentifierComponent,
    LockComponent,
    TippyComponent,
    BlockLayout
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
      if (this.typeListSelected === 'local') {
        return !this.namespace || !this.identifier
      } else if (this.typeListSelected === 'global') {
        return !this.typeSelected || !this.identifier
      }

      return this.typeListSelected ? !this.identifier : true
    }
  },

  created () {
    Identifier.types().then(({ body }) => {
      const list = body
      const keys = Object.keys(body)
      keys.forEach(key => {
        const itemList = list[key]
        itemList.common = Object.fromEntries(itemList.common.map(item => ([item, Object.entries(itemList.all).find(([key, value]) => key === item)[1]])))
      })
      this.typeList = body
    })
  },

  methods: {
    addIdentifier () {
      const data = {
        namespace_id: this.namespace?.id,
        object_tag: [this.namespace?.name || '', this.identifier].filter(item => item).join(' '),
        identifier: this.identifier,
        type: this.typeSelected,
        identifier_object_type: 'Extract'
      }

      this.$store.commit(MutationNames.AddIdentifier, data)
    },

    resetIdentifier () {
      this.namespace = undefined
      this.identifier = undefined
    },

    removeIdentifier (index) {
      if (this.identifiers[index].id) {
        Identifier.destroy(this.identifiers[index].id)
      }
      this.$store.commit(MutationNames.RemoveIdentifierByIndex, index)
    }
  }
}
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
