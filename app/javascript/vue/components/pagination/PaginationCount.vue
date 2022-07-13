<template>
  <div class="horizontal-left-content">
    <span
      v-if="haveRecords"
      class="horizontal-left-content"
    >
      {{ recordsAtCurrentPage }} - 
      {{ recordsAtNextPage }} of {{ pagination.total }} records.
    </span>
    <span v-else>0 records.</span>
    <div class="margin-small-left">
      <select v-model="per">
        <option
          v-for="records in maxRecords"
          :key="records"
          :value="records"
        >
          {{ records }}
        </option>
      </select>
      records per page.
    </div>
  </div>
</template>

<script>
export default {
  props: {
    pagination: {
      type: Object,
      required: true
    },

    modelValue: {
      type: [String, Number],
      required: true
    },

    maxRecords: {
      type: Array,
      default: () => [50, 100, 250, 500, 1000]
    }
  },

  emits: ['update:modelValue'],

  computed: {
    recordsAtCurrentPage () {
      return ((this.pagination.paginationPage - 1) * this.pagination.perPage) || 1
    },

    recordsAtNextPage () {
      const recordsCount = this.pagination.paginationPage * this.pagination.perPage
      return recordsCount > this.pagination.total ? this.pagination.total : recordsCount
    },

    haveRecords () {
      return Number(this.pagination.total)
    },

    per: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
