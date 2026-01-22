<template>
  <div class="panel type-specimen-box">
    <spinner
      :show-spinner="false"
      :show-legend="false"
      v-if="!store.taxonName?.id"
    />
    <div class="header flex-separate middle">
      <h3>Metadata</h3>
    </div>
    <div class="body">
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
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { TypeMaterial } from '@/routes/endpoints'
import Spinner from '@/components/ui/VSpinner.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import useStore from '../store/store.js'

const store = useStore()
const types = ref({})

TypeMaterial.types().then(({ body }) => {
  types.value = body
})
</script>
