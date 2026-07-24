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
      >
        <template #tabs-right>
          <div class="w-full horizontal-right-content">
            <lock-component v-model="locked" />
          </div>
        </template>
      </smart-selector>
    </div>
    <template v-if="repositorySelected">
      <hr class="divisor" />
      <SmartSelectorItem
        class="padding-medium-top padding-medium-bottom"
        :item="repositorySelected"
        @unset="setRepository(null)"
      />
    </template>
  </fieldset>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Repository } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector'
import LockComponent from '@/components/ui/VLock/index.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  repositoryId: {
    type: Number,
    default: undefined
  },

  lock: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['update:lock', 'select'])

const repositorySelected = ref(undefined)

const locked = defineModel('lock', {
  type: Boolean,
  required: true
})

watch(
  () => props.repositoryId,
  (newVal) => {
    if (newVal) {
      Repository.find(newVal).then((response) => {
        repositorySelected.value = response.body
      })
    } else {
      repositorySelected.value = undefined
    }
  },
  { immediate: true }
)

function setRepository(repository) {
  emit('select', repository?.id || null)
}
</script>
