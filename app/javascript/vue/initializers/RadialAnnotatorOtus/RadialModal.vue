<template>
  <RadialAnnotator
    v-if="hasOnlyOneOTU"
    :global-id="otus[0].global_id"
  />
  <div v-else>
    <VModal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Radial annotators</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="otu in otus"
            :key="otu.id"
            class="horizontal-left-content middle gap-small"
          >
            <span v-html="otu.object_tag" />
            <RadialAnnotator :global-id="otu.global_id" />
          </li>
        </ul>
      </template>
    </VModal>
    <VBtn
      circle
      color="radial"
      title="Radial annotator"
      :disabled="otus.length === 0"
      @click="() => (isModalVisible = true)"
    >
      <VIcon
        :title="buttonTitle"
        name="radialAnnotator"
        x-small
      />
    </VBtn>
  </div>
</template>

<script setup>
import { Otu } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

const props = defineProps({
  taxonNameId: {
    type: String,
    required: true
  }
})

const otus = ref([])
const hasOnlyOneOTU = computed(() => otus.value.length === 1)
const isModalVisible = ref(false)

Otu.where({ taxon_name_id: [props.taxonNameId] }).then(({ body }) => {
  otus.value = body
})
</script>
