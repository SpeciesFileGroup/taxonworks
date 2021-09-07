<template>
  <tr
    class="list-complete-item">
    <td>
      <input
        type="checkbox"
        :value="{
          id: item.id,
          loan_item_object_type: item.loan_item_object_type,
          loan_item_object_id: item.loan_item_object_id
        }"
        v-model="editLoanItems"
      >
    </td>
    <td>
      <span v-html="item.loan_item_object_tag"/>
    </td>
    <td>
      <input
        v-model="itemDate"
        type="date">
    </td>
    <td>
      <select v-model="itemStatus">
        <option
          v-for="status in statusList"
          :key="status"
          :value="status">
          {{ status }}
        </option>
      </select>
    </td>
    <td
      v-if="isOtu">
      <input
        :value="item.total"
        @blur="updateTotal"
        type="number">
    </td>
    <td
      v-else
      v-html="item.total"/>
    <td>
      <pin-component
        :object-id="item.loan_item_object_id"
        :type="item.loan_item_object_type"/>
    </td>
    <td>
      <radial-annotator :global-id="item.global_id"/>
    </td>
    <td>
      <span
        class="circle-button btn-delete"
        @click="$emit('onDelete', item)">Remove
      </span>
    </td>
  </tr>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import statusList from '../../const/status.js'
import PinComponent from 'components/ui/Pinboard/VPin.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'

export default {
  components: {
    PinComponent,
    RadialAnnotator
  },

  props: {
    item: {
      type: Object,
      required: true
    }
  },

  emits: [
    'onDelete',
    'onUpdate'
  ],

  data () {
    return {
      statusList
    }
  },

  computed: {
    editLoanItems: {
      get () {
        return this.$store.getters[GetterNames.GetEditLoanItems]
      },
      set (value) {
        this.$store.commit(MutationNames.SetEditLoanItems, value)
      }
    },

    itemStatus: {
      get () {
        return this.item.disposition
      },
      set (value) {
        this.$emit('onUpdate', { id: this.item.id, disposition: value })
      }
    },

    itemDate: {
      get () {
        return this.item.date_returned
      },
      set (value) {
        this.$emit('onUpdate', { id: this.item.id, date_returned: value })
      }
    },

    isOtu () {
      return this.item.loan_item_object_type === 'Otu'
    }
  },

  methods: {
    updateTotal (event) {
      if (this.item.total !== Number(event.target.value)) {
        this.$emit('onUpdate', { id: this.item.id, total: event.target.value })
      }
    }
  }
}
</script>
