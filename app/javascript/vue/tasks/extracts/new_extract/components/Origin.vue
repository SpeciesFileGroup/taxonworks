<template>
  <block-layout>
    <template #header>
      <h3>Origin</h3>
    </template>
    <template #body>
      <div>
        <template v-if="!originRelationship.oldObject">
          <div class="horizontal-left-content middle margin-small-bottom">
            <switch-component
              v-model="tabSelected"
              :options="tabsOptions"/>
            <lock-component
              class="margin-small-left"
              v-model="settings.lock.originRelationship"/>
          </div>

          <smart-selector
            :model="smartConfig.model"
            klass="Extract"
            target="Extract"
            @selected="setOrigin"/>
        </template>

        <div
          v-if="originRelationship.object_tag"
          class="horizontal-left-content">
          <span v-html="originRelationship.object_tag"/>
          <button
            class="button circle-button btn-undo button-default"
            type="button"
            @click="originRelationship = {}"/>
          <lock-component
            class="margin-small-left"
            v-model="settings.lock.originRelationship"/>
        </div>

        <div
          v-if="!isExtract"
          class="field label-above margin-medium-top">
          <label>Verbatim anatomical origin</label>
          <input
            type="text"
            v-model="extract.verbatim_anatomical_origin">
        </div>
      </div>
    </template>
  </block-layout>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import SwitchComponent from 'components/switch'
import LockComponent from 'components/ui/VLock/index.vue'
import BlockLayout from 'components/layout/BlockLayout'
import componentExtend from './mixins/componentExtend'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

const smartTypes = [
  {
    label: 'CollectionObject',
    model: 'collection_objects'
  },
  {
    label: 'Extract',
    model: 'extracts'
  },
  {
    label: 'Otu',
    model: 'otus'
  }
]

export default {
  mixins: [componentExtend],
  components: {
    BlockLayout,
    LockComponent,
    SmartSelector,
    SwitchComponent
  },

  data () {
    return {
      smartTypes: smartTypes,
      tabSelected: smartTypes[0].label
    }
  },

  computed: {
    smartConfig () {
      return this.smartTypes.find(type => type.label === this.tabSelected)
    },

    tabsOptions () {
      return this.smartTypes.map(({ label }) => label)
    },

    isExtract () {
      return this.tabSelected === smartTypes[1].label
    },

    originRelationship: {
      get () {
        return this.$store.getters[GetterNames.GetOriginRelationship]
      },
      set (value) {
        this.$store.commit(MutationNames.SetOriginRelationship, value)
      }
    }
  },

  watch: {
    isExtract (newVal) {
      if (newVal) {
        this.extract.verbatim_anatomical_origin = undefined
      }
    },
    originRelationship ({ oldObject }) {
      if (oldObject) {
        this.tabSelected = oldObject.old_object_type
      }
    }
  },

  methods: {
    setOrigin ({ base_class, id, object_tag }) {
      this.originRelationship = {
        object_tag,
        oldObject: {
          old_object_id: id,
          old_object_type: base_class || 'CollectionObject'
        }
      }
    }
  }
}
</script>
