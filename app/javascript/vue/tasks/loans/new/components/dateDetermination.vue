<template>
  <div>
    <span><b>Update determinations</b></span>
    <hr />
    <div class="field">
      <label>Determiner</label>
      <role-picker
        v-model="roles"
        role-type="Determiner"
      />
    </div>
    <div class="field">
      <label>OTU</label>
      <span
        class="middle"
        v-if="otuSelected"
      >
        <span
          v-html="otuSelected"
          class="margin-small-right"
        />
        <span
          @click="
            () => {
              otuSelected = undefined
              determination.otu_id = undefined
            }
          "
          class="button button-circle btn-undo button-default"
        />
      </span>
      <otu-picker
        v-else
        clear-after
        @get-item="
          (otu) => {
            determination.otu_id = otu.id
            otuSelected = otu.object_tag
          }
        "
      />
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
      type="button"
    >
      Set determination
    </button>
  </div>
</template>
<script>
import { COLLECTION_OBJECT, CONTAINER } from '@/constants/index.js'
import { TaxonDetermination, Container } from '@/routes/endpoints'
import { MutationNames } from '../store/mutations/mutations'
import DateFields from '@/components/ui/Date/DateFields.vue'
import rolePicker from '@/components/role_picker.vue'
import OtuPicker from '@/components/otu/otu_picker/otu_picker'

export default {
  components: {
    OtuPicker,
    rolePicker,
    DateFields
  },

  props: {
    list: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    validateFields() {
      return this.determination.otu_id && this.list.length
    },
    roles: {
      get() {
        return this.determination.roles_attributes
      },
      set(value) {
        this.determination.roles_attributes = value
      }
    }
  },

  data() {
    return {
      otuSelected: undefined,
      determination: {
        taxon_determination_object_id: undefined,
        otu_id: undefined,
        year_made: undefined,
        month_made: undefined,
        day_made: undefined,
        roles_attributes: []
      }
    }
  },

  methods: {
    setDeterminations() {
      const promises = []

      this.$store.commit(MutationNames.SetSaving, true)
      this.list.forEach((item) => {
        if (item.loan_item_object_type === CONTAINER) {
          this.getCollectionOjectsFromContainer(item.loan_item_object_id).then(
            (ids) => {
              ids.forEach((id) => {
                promises.push(
                  this.createDetermination({
                    taxon_determination_object_id: id,
                    taxon_determination_object_type: COLLECTION_OBJECT
                  })
                )
              })
            }
          )
        } else if (item.loan_item_object_type === COLLECTION_OBJECT) {
          promises.push(
            this.createDetermination({
              taxon_determination_object_id: item.loan_item_object_id,
              taxon_determination_object_type: COLLECTION_OBJECT
            })
          )
        }
      })

      Promise.all(promises).then(() => {
        this.$store.commit(MutationNames.SetSaving, false)
        TW.workbench.alert.create(
          'Loan item was successfully updated.',
          'notice'
        )
      })
    },

    createDetermination(params = {}) {
      const payload = {
        ...this.determination,
        ...params
      }

      return TaxonDetermination.create({ taxon_determination: payload })
    },

    getCollectionOjectsFromContainer(containerId) {
      return new Promise((resolve, reject) => {
        Container.find(containerId).then(({ body }) => {
          const containerItems = body.container_items

          resolve(
            containerItems.map(
              (item) => item.container_item.contained_object_id
            )
          )
        })
      })
    }
  }
}
</script>
