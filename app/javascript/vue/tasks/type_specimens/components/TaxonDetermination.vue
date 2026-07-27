<template>
  <fieldset>
    <legend>Taxon determination</legend>
    <template v-if="store.taxonDeterminations.length">
      <ul class="no_bullets">
        <li
          v-for="td in store.taxonDeterminations"
          :key="td.id"
          class="flex-separate gap-small"
        >
          <span v-html="td.otu.object_tag" />
          <VBtn
            color="destroy"
            icon
            variant="tonal"
            @click="removeTaxonDetermination(td)"
          >
            <IconTrash class="w-4 h-4" />
          </VBtn>
        </li>
      </ul>
    </template>
    <template v-else>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              :value="undefined"
              v-model="store.selectedOtuId"
            />
            None
          </label>
        </li>
        <li
          v-for="otu in otus"
          :key="otu.id"
        >
          <label>
            <input
              type="radio"
              :value="otu.id"
              v-model="store.selectedOtuId"
            />
            <span v-html="otu.object_tag" />
          </label>
        </li>
      </ul>
    </template>
  </fieldset>
</template>

<script setup>
import { Otu } from '@/routes/endpoints'
import { ref } from 'vue'
import useStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

const store = useStore()
const otus = ref([])

Otu.where({ taxon_name_id: store.taxonName.id }).then(({ body }) => {
  otus.value = body
  if (body.length === 1 && store.selectedOtuId === undefined) {
    store.selectedOtuId = body[0].id
  }
})

function removeTaxonDetermination(td) {
  if (
    window.confirm(
      `You're trying to delete this record. Are you sure you want to proceed?`
    )
  ) {
    store.removeTaxonDetermination(td)
  }
}
</script>
