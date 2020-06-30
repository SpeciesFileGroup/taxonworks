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
      value: {
        type: Object,
        required: true
      }
    },
    data: function () {
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
          this.$delete(this.selectedList, item.id)
        }
        else {
          this.$set(this.selectedList, item.id, item);
        }
        this.$emit('input', this.selectedList);
      }
    }
  }
</script>