<template>
  <block-layout>
    <template #header>
      <h3>Repository</h3>
    </template>
    <template #body>
      <fieldset class="fieldset">
        <legend>Repository</legend>
        <div class="margin-small-bottom horizontal-left-content align-start">
          <smart-selector
            class="full_width"
            ref="smartSelector"
            model="repositories"
            target="CollectionObject"
            klass="CollectionObject"
            pin-section="Repositories"
            pin-type="Repository"
            @selected="setRepository"
          />
          <lock-component
            class="margin-small-left"
            v-model="settings.lock.repository"
          />
        </div>
        <template v-if="repository">
          <div class="middle separate-top">
            <span data-icon="ok" />
            <span class="separate-right"> {{ repository.object_tag }}</span>
            <span
              class="circle-button button-default btn-undo"
              @click="setRepository(undefined)"
            />
          </div>
        </template>
      </fieldset>
    </template>
  </block-layout>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import componentExtend from './mixins/componentExtend'
import LockComponent from 'components/ui/VLock/index.vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { Repository } from 'routes/endpoints'
import BlockLayout from 'components/layout/BlockLayout'

export default {
  mixins: [componentExtend],

  components: {
    LockComponent,
    SmartSelector,
    BlockLayout
  },

  computed: {
    repository: {
      get () {
        return this.$store.getters[GetterNames.GetRepository]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRepository, value)
      }
    }
  },

  watch: {
    extract (newVal) {
      if (newVal.repository_id) {
        Repository.find(newVal.repository_id).then(({ body }) => {
          this.setRepository(body)
        })
      }
    }
  },

  methods: {
    setRepository (repository) {
      this.repository = repository
    }
  }
}
</script>
