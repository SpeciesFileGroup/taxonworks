<template>
  <div>
    <button
      v-for="member in membersList"
      :key="member.id"
      type="button"
      :class="{ 'button-default': !(selectedList.hasOwnProperty(member.id))}"
      class="button normal-input biocuration-toggle-button"
      @click="selectMember(member)"
      v-html="member.user.name"/>
  </div>
</template>

<script>
import AjaxCall from 'helpers/ajaxCall'

export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      membersList: [],
      selectedList: {}
    }
  },
  watch: {
    value(newVal) {
      this.selectedList = newVal
    }
  },
  mounted: function () {
    AjaxCall('get', '/project_members.json').then(response => {
      this.membersList = response.body
    })
  },
  methods: {
    selectMember(item) {
      if (this.selectedList.hasOwnProperty(item.id)) {
        delete this.selectedList[item.id]
      }
      else {
        this.selectedList[item.id] = item
      }
      this.$emit('update:modelValue', this.selectedList);
    }
  }
}
</script>