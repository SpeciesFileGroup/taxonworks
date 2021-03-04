<template>
  <div class="panel container">
    <h2>Identifier</h2>
    <div class="flex-wrap-column middle align-start full_width">

      <div v-if="typeListSelected">
        <span class="capitalize">{{ typeListSelected }}</span>
        <button
          class="button button-default"
          @click="typeListSelected = undefined">
          Change
        </button>
        <select-type
          :list="typeList[typeListSelected]"
          v-model="typeSelected"/>
      </div>

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

    </div>
  </div>
</template>

<script>

import { GetIdentifierTypes } from '../request/resources'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

import componentExtend from './mixins/componentExtend'
import SelectType from './Identifiers/SelectType'

export default {
  mixins: [componentExtend],

  components: { SelectType },

  data () {
    return {
      existingIdentifier: undefined,
      delay: 1000,
      saveRequest: undefined,
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
    }
  }
}
</script>

<style scoped>
  .validate-identifier {
    border: 1px solid red
  }
</style>
