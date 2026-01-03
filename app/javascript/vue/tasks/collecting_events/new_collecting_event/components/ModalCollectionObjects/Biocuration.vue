<template>
  <div>
    <h3>Biocurations</h3>
    <div>
      <div v-for="group in biocurationGroups">
        <label class="d-block">{{ group.name }}</label>

        <VBtn
          v-for="item in group.list"
          :key="item.id"
          :color="!biocurations.includes(item.id) ? 'primary' : ''"
          medium
          class="biocuration-toggle-button"
          @click="toggleBiocuration(item)"
        >
          {{ item.name }}
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm, Tag } from '@/routes/endpoints'
import { BIOCURATION_CLASS, BIOCURATION_GROUP } from '@/constants'
import VBtn from '@/components/ui/VBtn/index.vue'

const biocurations = defineModel({
  type: Array,
  required: true
})

const biocurationTypes = ref([])
const biocurationGroups = ref([])

onBeforeMount(async () => {
  const { body } = await ControlledVocabularyTerm.where({
    type: [BIOCURATION_CLASS, BIOCURATION_GROUP]
  })

  biocurationTypes.value = body.filter((b) => b.type === BIOCURATION_CLASS)
  biocurationGroups.value = body.filter((b) => b.type === BIOCURATION_GROUP)

  splitGroups()
})

function toggleBiocuration(biocuration) {
  const index = biocurations.value.findIndex((id) => id === biocuration.id)

  if (index > -1) {
    biocurations.value.splice(index, 1)
  } else {
    biocurations.value.push(biocuration.id)
  }
}

function splitGroups() {
  biocurationGroups.value.forEach((item, index) => {
    Tag.where({ keyword_id: item.id }).then((response) => {
      const list = biocurationTypes.value.filter((biocurationType) =>
        response.body.find((item) => biocurationType.id === item.tag_object_id)
      )
      biocurationGroups.value[index]['list'] = list
    })
  })
}
</script>

<style>
.biocuration-toggle-button {
  min-width: 60px;
  border: 0px;
  margin-right: 6px;
  margin-bottom: 6px;
  border-top-left-radius: 14px;
  border-bottom-left-radius: 14px;
}
</style>
