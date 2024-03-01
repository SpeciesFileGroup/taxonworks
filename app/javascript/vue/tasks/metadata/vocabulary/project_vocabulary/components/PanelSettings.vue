<template>
  <div class="flex-col gap-small">
    <div>
      <label class="d-block">Model</label>
      <select
        v-model="parameters.model"
        class="full_width"
      >
        <option
          disabled
          :value="undefined"
        >
          Select...
        </option>
        <option
          v-for="model in models"
          :key="model"
          :value="model"
        >
          {{ model }}
        </option>
      </select>
    </div>

    <div>
      <label class="d-block">Attribute</label>
      <select
        v-model="parameters.attribute"
        class="full_width"
      >
        <option
          disabled
          :value="undefined"
        >
          {{ parameters.model ? 'Select...' : 'Select a model first.' }}
        </option>
        <option
          v-for="attr in attributes"
          :key="attr"
          :value="attr"
        >
          {{ attr }}
        </option>
      </select>
    </div>

    <div>
      <label class="d-block">Contains</label>
      <input
        type="text"
        class="full_width"
        v-model="parameters.contains"
      />
    </div>

    <div>
      <label class="d-block">Begining with</label>
      <input
        class="full_width"
        type="text"
        v-model="parameters.begining_with"
      />
    </div>

    <div class="horizontal-left-content gap-small">
      <div>
        <label class="d-block">Min</label>
        <input
          type="number"
          v-model="parameters.min"
        />
      </div>
      <div>
        <label class="d-block">Max</label>
        <input
          type="number"
          v-model="parameters.max"
        />
      </div>
    </div>

    <div>
      <label class="d-block">Limit (maximum number of records to return)</label>
      <input
        v-between-numbers="[1, 100]"
        type="number"
        v-model="parameters.limit"
      />
    </div>
  </div>
</template>

<script setup>
import { Metadata } from '@/routes/endpoints'
import { ref, onBeforeMount, watch } from 'vue'
import { vBetweenNumbers } from '@/directives'

const parameters = defineModel({
  type: Object,
  required: true
})

const models = ref([])
const attributes = ref([])

watch(
  () => parameters.value.model,
  (newVal) => {
    parameters.value.attribute = undefined

    if (newVal) {
      Metadata.attributes({ model: newVal }).then(({ body }) => {
        attributes.value = body
      })
    }
  }
)

onBeforeMount(() => {
  Metadata.dataModels().then(({ body }) => {
    models.value = body
  })
})
</script>
