<template>
  <div>
    <h2>Select model</h2>
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.value"
      >
        <label>
          <input 
            type="radio"
            name="model"
            :value="item.value"
            @click="selectOption(item)"
          >
          {{ item.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      list: [
        {
          label: 'Otu',
          value: 'Otu'
        },
        {
          label: 'Asserted distribution',
          value: 'AssertedDistribution'
        },
        {
          label: 'Collection object',
          value: 'CollectionObject'
        },
        {
          label: 'Collecting Event',
          value: 'CollectingEvent'
        },
        {
          label: 'Extract',
          value: 'Extract'
        }
      ],
      selected: undefined
    }
  },
  methods: {
    selectOption(item) {
      this.selected = item
      this.$emit('onSelect', item)
    }
  }
}
</script>

<style>

</style>
