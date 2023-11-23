<template>
  <div>
    <fieldset>
      <legend>Taxon name</legend>
      <SmartSelector
        model="taxon_names"
        :klass="TAXON_NAME"
        :target="TAXON_NAME"
        @selected="(item) => (taxon_name = item)"
      />
      <SmartSelectorItem
        :item="taxon_name"
        label="name"
        @unset="taxon_name = undefined"
      />
    </fieldset>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!taxon_name"
      @click="handleUpdate"
    >
      Update
    </VBtn>

    <div class="margin-large-top">
      <template v-if="otuUpdated.moved.length">
        <h3>Moved</h3>
        <ul>
          <li
            v-for="item in otuUpdated.moved"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseOtu}?otu_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
      <template v-if="otuUpdated.unmoved.length">
        <h3>Unmoved</h3>
        <ul>
          <li
            v-for="item in otuUpdated.unmoved"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseOtu}?otu_id=${item.id}`"
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
import { Otu } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants/index.js'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const taxon_name = ref()
const confirmationModalRef = ref(null)
const otuUpdated = ref({ moved: [], unmoved: [] })

function move() {
  const payload = {
    otu_query: props.parameters,
    taxon_name_id: taxon_name.value.id
  }

  Otu.moveBatch(payload).then(({ body }) => {
    otuUpdated.value = body
    TW.workbench.alert.create(
      `${body.moved.length} OTUs were successfully updated.`,
      'notice'
    )
  })
}


async function handleUpdate() {
  const ok =
    (await confirmationModalRef.value.show({
      title: 'Change taxon name ',
      message:
        'This will change the taxon name for the selected OTUs. Are you sure you want to proceed?',
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
