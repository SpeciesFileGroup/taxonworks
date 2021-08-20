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
    <div class="align-start margin-medium-top">
      <smart-selector
        model="namespaces"
        klass="CollectionObject"
        pin-section="Namespaces"
        pin-type="Namespace"
        @selected="setValue"/>
      <lock-component
        class="margin-small-left"
        v-model="lock.identifier"/>
    </div>
    <p
      v-if="identifier.namespace_id"
      class="middle">
      <span
        class="margin-small-right"
        v-html="identifier.label"/>
      <span
        class="button-circle button-default btn-undo"
        @click="removeNamespace"/>
    </p>
    <div class="horizontal-left-content">
      <div class="margin-small-top margin-small-right full_width">
        <label class="display-block">Identifier</label>
        <input
          class="full_width"
          v-model="identifier.identifier"
          type="number">
      </div>
      <div class="margin-small-top margin-small-left full_width">
        <label class="display-block">End</label>
        <input
          class="full_width"
          :value="incremented"
          disabled="true"
          type="number">
      </div>
    </div>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],
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
    },
    incremented () {
      if(!this.identifier.identifier) return undefined

      let inc = 0

      this.sledImage.metadata.forEach(item => {
        if(item.metadata == null) {
          inc ++
        }
      })
      return (Number(this.identifier.identifier) + inc + (inc == 0 ? 0 : -1))
    }
  },
  data () {
    return {
      tabs: [],
      lists: undefined,
      view: undefined,
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
  methods: {
    setValue (value) {
      this.identifier.namespace_id = value.id
      this.identifier.label = value.name
    },
    resetIdentifier () {
      this.identifier = {
        id: undefined,
        identifier: undefined,
        label: undefined,
        namespace_id: undefined,
        type: "Identifier::Local::CatalogNumber",
        identifier_object_id: undefined,
        identifier_object_type: 'CollectionObject'
      }
    },
    removeNamespace () {
      this.identifier.namespace_id = undefined
      this.identifier.label = undefined
    }
  }
}
</script>
