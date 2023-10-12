<template>
  <div>
    <fieldset>
      <legend>Taxon name</legend>
      <SmartSelector
        model="taxon_names"
        :klass="TAXON_NAME"
        :target="TAXON_NAME"
        @selected="(item) => (parent = item)"
      />
      <SmartSelectorItem
        :item="parent"
        label="name"
        @unset="parent = undefined"
      />
    </fieldset>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!parent"
      @click="handleUpdate"
    >
      Update
    </VBtn>

    <div class="margin-large-top">
      <template v-if="taxonNameUpdated.moved.length">
        <h3>Moved</h3>
        <ul>
          <li
            v-for="item in taxonNameUpdated.moved"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseNomenclature}?taxon_name_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
      <template v-if="taxonNameUpdated.unmoved.length">
        <h3>Unmoved</h3>
        <ul>
          <li
            v-for="item in taxonNameUpdated.unmoved"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseNomenclature}?taxon_name_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
    </div>
    <ConfirmationModal ref="confirmationModalRef"/>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes.js'
import { TaxonName } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants/index.js'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const parent = ref()
const confirmationModalRef = ref(null)
const taxonNameUpdated = ref({ moved: [], unmoved: [] })

function move() {
  const payload = {
    taxon_name_query: props.parameters,
    parent_id: parent.value.id
  }

  TaxonName.moveBatch(payload).then(({ body }) => {
    taxonNameUpdated.value = body
    TW.workbench.alert.create(
      `${body.moved.length} taxon names were successfully updated.`,
      'notice'
    )
  })
}


async function handleUpdate() {
  const ok =
    (await confirmationModalRef.value.show({
      title: 'Change parent ',
      message:
        'This will change the parent of the taxon names. Are you sure you want to proceed?',
      confirmationWord: 'CHANGE',
      okButton: 'Update',
      cancelButton: 'Cancel',
      typeButton: 'submit'
    }))

  if (ok) {
    move()
  }
}
</script>
