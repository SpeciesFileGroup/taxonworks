<template>
  <div>
    <span><b>Update determinations</b></span>
    <hr>
    <div class="field">
      <label>Determiner</label>
      <role-picker
        v-model="roles"
        role-type="Determiner"/>
    </div>
    <div class="field">
      <label>OTU</label>
      <span
        class="middle"
        v-if="otuSelected"
      >
        <span
          v-html="otuSelected"
          class="margin-small-right"/>
        <span
          @click="otuSelected = undefined; determination.otu_id = undefined"
          class="button button-circle btn-undo button-default"/>
      </span>
      <otu-picker
        v-else
        :clear-after="true"
        @getItem="determination.otu_id = $event.id; otuSelected = $event.label_html"/>
    </div>
    <div class="field">
      <label>Date made</label>
      <date-fields
        v-model:year="determination.year_made"
        v-model:month="determination.month_made"
        v-model:day="determination.day_made"
      />
    </div>
    <button
      @click="setDeterminations()"
      class="button button-submit normal-input"
      :disabled="!validateFields"
      type="button">Set determination
    </button>
  </div>
</template>
<script>

import DateFields from 'components/ui/Date/DateFields.vue'
import { TaxonDetermination } from 'routes/endpoints'
import { MutationNames } from '../store/mutations/mutations'
import rolePicker from 'components/role_picker.vue'
import OtuPicker from 'components/otu/otu_picker/otu_picker'

export default {
  components: {
    OtuPicker,
    rolePicker,
    DateFields
  },
  props: {
    list: {
      type: Array,
      default: () => {
        return []
      }
    }
  },
  computed: {
    validateFields () {
      return this.determination.otu_id &&
        this.list.length
    },
    roles: {
      get () {
        return this.determination.roles_attributes
      },
      set (value) {
        this.determination.roles_attributes = value
      }
    }
  },
  data () {
    return {
      otuSelected: undefined,
      determination: {
        biological_collection_object_id: undefined,
        otu_id: undefined,
        year_made: undefined,
        month_made: undefined,
        day_made: undefined,
        roles_attributes: []
      }
    }
  },
  methods: {
    setDeterminations () {
      const newDetermination = this.determination
      const promises = []

      this.$store.commit(MutationNames.SetSaving, true)
      this.list.forEach(item => {
        if (item.loan_item_object_type === 'CollectionObject') {
          newDetermination.biological_collection_object_id = item.loan_item_object_id
          promises.push(TaxonDetermination.create({ taxon_determination: newDetermination }))
        }
      })
      Promise.all(promises).then(() => {
        this.$store.commit(MutationNames.SetSaving, false)
        TW.workbench.alert.create('Loan item was successfully updated.', 'notice')
      })
    }
  }
}
</script>
