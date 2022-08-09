<template>
  <div>
    <ul class="no_bullets">
      <li
        v-for="item in list"
        :key="item.id">
        <label
          v-if="!alreadyExist(item)">
          <input
            name="dynamic-taxon"
            type="radio"
            @click="selectItem(item)">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    list: {
      type: Array,
      required: true
    },
    createdList: {
      type: Array,
      required: true
    },
    valueCompare: {
      type: String,
      required: true
    }
  },
  methods: {
    alreadyExist (object) {
      return this.createdList.find(item => { return item[this.valueCompare] === object.id })
    },
    selectItem(item) {
      this.$emit('selected', item)
    }
  }
}
</script>
