<template>
  <BlockLayout class="panel type-specimen-box">
    <template #header>
      <h3>Metadata</h3>
    </template>
    <template #body>
      <label>Type</label>
      <div class="flex-wrap-row separate-top separate-bottom">
        <template v-if="store.taxonName && types">
          <ul class="flex-wrap-column no_bullets">
            <li
              v-for="(_, key) in types[store.taxonName.nomenclatural_code]"
              :key="key"
            >
              <label class="capitalize">
                <input
                  v-model="store.typeMaterial.type"
                  type="radio"
                  name="typetype"
                  :value="key"
                  @change="() => (store.typeMaterial.isUnsaved = true)"
                />
                {{ key }}
              </label>
            </li>
          </ul>
        </template>
      </div>
      <div class="field">
        <FormCitation
          :original="false"
          :new-button="false"
          v-model="store.typeMaterial.citation"
          @update="() => (store.typeMaterial.isUnsaved = true)"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref } from 'vue'
import { TypeMaterial } from '@/routes/endpoints'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import Spinner from '@/components/ui/VSpinner.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import useStore from '../store/store.js'

const store = useStore()
const types = ref({})

TypeMaterial.types().then(({ body }) => {
  types.value = body
})
</script>
