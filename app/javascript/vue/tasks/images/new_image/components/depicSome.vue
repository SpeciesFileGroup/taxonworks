<template>
  <div class="panel content">
    <h2>Depict some</h2>
    <div class="flex-separate align-start">
      <ul class="no_bullets">
        <li
          v-for="item in objectTypes"
          :key="item.key">
          <label>
            <input
              v-model="selectedType"
              type="radio"
              name="depicsome"
              :value="item"
            >
            {{ item.label }}
          </label>
        </li>
      </ul>
      <smart-selector
        :otu-picker="isOtuType"
        :autocomplete="!isOtuType"
        v-if="selectedType"
        :model="selectedType.model"
        :klass="selectedType.key"
        target="Depiction"
        @selected="addToList"/>
    </div>
    <table-list
      :list="listCreated"
      :header="['Objects', 'Remove']"
      :delete-warning="false"
      :annotator="false"
      @delete="removeItem"
      :attributes="['label']"/>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import TableList from 'components/table_list'

import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'

export default {
  components: {
    SmartSelector,
    TableList
  },

  computed: {
    listCreated () {
      return this.$store.getters[GetterNames.GetObjectsForDepictions]
    },

    isOtuType () {
      return this.selectedType?.key === 'Otu'
    }
  },

  data () {
    return {
      objectTypes: [
        {
          key: 'Otu',
          label: 'Otu',
          model: 'otus'
        },
        {
          key: 'CollectingEvent',
          label: 'Collecting event',
          model: 'collecting_events'
        },
        {
          key: 'CollectionObject',
          label: 'Collection object',
          model: 'collection_objects'
        }
      ],
      selectedType: undefined
    }
  },

  methods: {
    removeItem (item) {
      this.$store.commit(MutationNames.RemoveObjectForDepictions, item)
    },

    addToList (item) {
      this.$store.commit(MutationNames.AddObjectForDepictions, {
        id: item.id,
        label: item.object_tag,
        base_class: this.selectedType.key
      })
    }
  }
}
</script>

<style scoped>
  li {
    margin-bottom: 4px;
  }
</style>
