<template>
  <FacetContainer>
    <h3>Biocurations</h3>
    <ul
      v-if="biocurations.length"
      class="no_bullets"
    >
      <li
        v-for="item in biocurations"
        :key="item.id"
        class="margin-small-bottom"
      >
        <label>
          <input
            type="checkbox"
            v-model="params.biocuration_class_ids"
            :value="item.id"
          >
          <span v-html="item.object_tag" />
        </label>
      </li>
    </ul>
    <a
      v-else
      href="/tasks/controlled_vocabularies/biocuration/build_collection"
    >
      Create new
    </a>
  </FacetContainer>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const biocurations = ref([])

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.biocuration_class_ids = urlParams.biocuration_class_ids || []
  ControlledVocabularyTerm.where({ type: ['BiocurationClass'] }).then(response => {
    biocurations.value = response.body
  })
})
</script>
