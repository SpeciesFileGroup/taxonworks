<template>
  <div>
    <label>Predicate</label>
    <SmartSelector
      ref="smartSelectorRef"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Predicate' }"
      get-url="/controlled_vocabulary_terms/"
      model="predicates"
      buttons
      inline
      klass="DataAttribute"
      :add-tabs="['all']"
      @selected="(p) => (predicate = p)"
    >
      <template #all>
        <VModal @close="smartSelectorRef.setTab('quick')">
          <template #header>
            <h3>Predicates - all</h3>
          </template>
          <template #body>
            <div class="flex-wrap-row gap-small">
              <VBtn
                v-for="item in list"
                :key="item.id"
                color="primary"
                pill
                @click="
                  () => {
                    predicate = item
                    smartSelectorRef.setTab('quick')
                  }
                "
              >
                {{ item.name }}
              </VBtn>
            </div>
          </template>
        </VModal>
      </template>
    </SmartSelector>
    <SmartSelectorItem
      :item="predicate"
      label="name"
      @unset="
        () => {
          predicate = undefined
        }
      "
    />
    <label>Value</label>
    <div class="field">
      <textarea
        v-model="inputValue"
        class="full_width"
        rows="5"
      />
      <div class="flex-separate middle">
        <div class="horizontal-left-content middle gap-small">
          <VBtn
            color="primary"
            medium
            :disabled="!predicate"
            @click="() => addPredicate({ any: false })"
          >
            Add
          </VBtn>
          <VBtn
            color="primary"
            medium
            :disabled="!predicate"
            @click="() => addPredicate({ any: true, text: '' })"
          >
            Any
          </VBtn>
        </div>
        <label>
          <input
            v-model="exact"
            type="checkbox"
          />
          Exact
        </label>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { PREDICATE } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'

const emit = defineEmits(['add'])
const smartSelectorRef = ref(null)
const inputValue = ref('')
const predicate = ref()
const exact = ref(false)
const list = ref([])

function addPredicate(params) {
  const data = {
    id: predicate.value.id,
    name: predicate.value.name,
    text: inputValue.value,
    exact: exact.value,
    ...params
  }

  inputValue.value = ''
  predicate.value = undefined

  emit('add', data)
}

function loadPredicates() {
  ControlledVocabularyTerm.where({ type: [PREDICATE] })
    .then(({ body }) => {
      list.value = body
    })
    .catch(() => {})
}

onBeforeMount(loadPredicates)
</script>
