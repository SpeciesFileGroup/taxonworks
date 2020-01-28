<template>
  <fieldset>
    <legend>Catalogue numbers</legend>
    <ul class="no_bullets">
      <li v-for="item in steps">
        <label>
          <input
            type="radio"
            name="step"
            v-model="sledImage.step_identifier_on"
            :value="item.value">
          {{ item.label }}
        </label>
      </li>
    </ul>
    <smart-selector
      class="margin-medium-top"
      model="namespaces"
      klass="CollectionObject"
      @selected="setValue"/>
    <p
      v-if="identifier.namespace_id"
      class="middle">
      <span
        class="margin-small-right"
        v-html="label"/>
      <span
        class="button-circle button-default btn-undo"
        @click="resetIdentifier"/>
    </p>
    <div class="margin-small-top">
      <label class="display-block">Identifier</label>
      <input
        v-model="identifier.identifier"
        type="text">
    </div>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  components: {
    SmartSelector
  },
  computed: {
    identifier: {
      get () {
        return this.$store.getters[GetterNames.GetIdentifier]
      },
      set (value) {
        this.$store.commit(MutationNames.SetIdentifier, value)
      }
    },
    sledImage: {
      get () {
        return this.$store.getters[GetterNames.GetSledImage]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSledImage, value)
      }
    }
  },
  data () {
    return {
      tabs: [],
      lists: undefined,
      view: undefined,
      label: undefined,
      steps: [
        {
          label: 'none',
          value: undefined
        },
        {
          label: 'down -> across',
          value: 'column'
        },
        {
          label: 'across -> down',
          value: 'row'
        }
      ]
    }
  },
  created () {
    this.resetIdentifier()
  },
  methods: {
    setValue(value) {
      this.identifier.namespace_id = value.id
      this.label = value.name
    },
    resetIdentifier () {
      this.label = undefined
      this.identifier = {
        id: undefined,
        identifier: undefined,
        namespace_id: undefined,
        type: "Identifier::Local::CatalogNumber",
        identifier_object_id: undefined,
        identifier_object_type: 'CollectionObject'
      }
    }
  }
}
</script>
