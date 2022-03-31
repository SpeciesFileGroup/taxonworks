<template>
  <fieldset class="fieldset">
    <legend>Repository</legend>
    <div class="horizontal-left-content align-start separate-bottom">
      <smart-selector
        class="full_width"
        ref="smartSelector"
        model="repositories"
        target="CollectionObject"
        klass="CollectionObject"
        pin-section="Repositories"
        pin-type="Repository"
        v-model="repositorySelected"
        @selected="setRepository"
      />
      <lock-component
        class="margin-small-left"
        v-model="locked"
      />
    </div>
    <template v-if="repositorySelected">
      <hr>
      <smart-selector-item
        :item="repositorySelected"
        @unset="setRepository(null)"
      />
    </template>
  </fieldset>
</template>

<script>
import { Repository } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector'
import LockComponent from 'components/ui/VLock/index.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'

export default {
  components: {
    SmartSelector,
    LockComponent,
    SmartSelectorItem
  },

  props: {
    repositoryId: {
      type: Number,
      default: undefined
    },

    lock: {
      type: Boolean,
      required: true
    }
  },

  emits: ['update:lock', 'select'],

  data () {
    return {
      repositorySelected: undefined
    }
  },

  computed: {
    locked: {
      get () {
        return this.lock
      },
      set (value) {
        this.$emit('update:lock', value)
      }
    }
  },

  watch: {
    repositoryId: {
      handler (newVal) {
        if (newVal) {
          Repository.find(newVal).then(response => {
            this.repositorySelected = response.body
          })
        } else {
          this.repositorySelected = undefined
        }
      },
      immediate: true
    }
  },

  methods: {
    setRepository (repository) {
      this.$emit('select', repository?.id || null)
    }
  }
}
</script>
