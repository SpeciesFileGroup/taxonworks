<template>
  <div class="app-container">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <VSpinner
      v-if="isCreating"
      full-screen
      legend="Creating OTUs..."
    />
    <div class="flex-separate middle">
      <h1>New OTU</h1>
      <VBtn
        color="primary"
        medium
        @click="
          () => {
            reset()
          }
        "
      >
        Reset
      </VBtn>
    </div>
    <TaxonNameSelector
      v-model:match="isMatch"
      v-model="taxonName"
      class="margin-medium-bottom"
    />

    <BlockLayout>
      <template #header>
        <h3>OTUs</h3>
      </template>
      <template #body>
        <div class="horizontal-left-content align-start gap-medium">
          <div class="width-30 flex-col">
            <InputNames
              class="full_width"
              v-model="names"
            />
            <VBtn
              color="primary"
              medium
              :disabled="!nameList.length"
              @click="() => getOtus(nameList)"
            >
              Find
            </VBtn>
          </div>
          <div class="full_width">
            <h2>Preview</h2>
            <div class="flex-separate middle margin-medium-bottom">
              {{ otuList.length }} OTUs
              <VBtn
                color="create"
                medium
                :disabled="!selected.length"
                @click="
                  () =>
                    createOTUs(
                      list.filter((item) => selected.includes(item.uuid))
                    )
                "
              >
                Create all OTUs
              </VBtn>
            </div>
            <TableOtu
              class="full_width"
              v-model="selected"
              :taxon-name="taxonName"
              :list="list"
              @create="
                ({ item }) => {
                  createOTUs([item])
                }
              "
            />
          </div>
        </div>
      </template>
    </BlockLayout>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { Otu, TaxonName } from '@/routes/endpoints'
import { randomUUID } from '@/helpers'
import TaxonNameSelector from './components/TaxonNameSelector.vue'
import InputNames from './components/InputNames.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import TableOtu from './components/TableOtu.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const names = ref('')
const taxonName = ref(null)
const taxonNameList = ref([])
const otuList = ref([])
const isMatch = ref(false)
const isLoading = ref(false)
const isCreating = ref(false)
const selected = ref([])
const nameList = computed(() => {
  return names.value.split('\n').filter(Boolean)
})

const list = computed(() =>
  otuList.value.map((otu) => ({
    uuid: otu.uuid,
    name: otu.name,
    exist: otu.exist,
    taxonName: isMatch.value
      ? taxonNameList.value.find((item) => item.cached === otu.name)
      : taxonName.value
  }))
)

watch([isMatch, taxonName], ([newVal]) => {
  otuList.value = []
  taxonNameList.value = []
  selected.value = []

  if (newVal) {
    taxonName.value = null
  }
})

function getOtus(otuNames) {
  const requests = []

  otuList.value = []
  taxonNameList.value = []
  isLoading.value = true

  otuNames?.forEach((name) => {
    requests.push(
      Otu.where({
        taxon_name_id: taxonName.value?.id,
        name,
        name_exact: true,
        per: 1
      }).then(({ body }) => {
        otuList.value.push({
          uuid: randomUUID(),
          name,
          exist: !!body.length
        })
      })
    )

    if (isMatch.value) {
      requests.push(
        TaxonName.where({
          name,
          name_exact: true
        }).then(({ body }) => {
          taxonNameList.value.push(...body)
        })
      )
    }
  })

  Promise.all(requests).then(() => {
    isLoading.value = false
    selected.value = otuList.value.map((item) => item.uuid)
  })
}

function createOTUs(otus) {
  const uuids = []

  isCreating.value = true

  const requests = otus.map((item) => {
    const payload = {
      otu: {
        name: item.name,
        taxon_name_id: item.taxonName?.id
      }
    }
    return Otu.create(payload).then(() => {
      uuids.push(item.uuid)
    })
  })

  Promise.all(requests).then(() => {
    const message =
      otus.length === 1
        ? 'OTU was successfully created.'
        : 'OTUs were successfully created.'

    otuList.value = otuList.value.filter((otu) => !uuids.includes(otu.uuid))
    isCreating.value = false

    TW.workbench.alert.create(message, 'notice')
  })
}

function reset() {
  taxonName.value = null
  otuList.value = []
  taxonNameList.value = []
  selected.value = []
  names.value = ''
}
</script>

<style scoped>
.app-container {
  width: 1240px;
  margin: 0 auto;
}
</style>
