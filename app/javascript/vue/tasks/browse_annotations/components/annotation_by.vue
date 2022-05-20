<template>
  <div>
    <button
      v-for="member in membersList"
      :key="member.id"
      type="button"
      :class="{ 'button-default': !selectedMembers.includes(member.id) }"
      class="button normal-input biocuration-toggle-button"
      @click="selectMember(member)"
      v-html="member.user.name"
    />
  </div>
</template>

<script>
import { ProjectMember } from 'routes/endpoints'

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
      membersList: []
    }
  },

  computed: {
    selectedMembers: {
      get () {
        return this.modelValue
      },

      set (value) {
        this.$emits('update:modelValue', value)
      }
    }
  },

  created () {
    ProjectMember.all().then(response => {
      this.membersList = response.body
    })
  },

  methods: {
    selectMember (item) {
      const index = this.selectedMembers.findIndex(memberId => memberId === item.id)

      if (index > -1) {
        this.selectedMembers.splice(index, 1)
      } else {
        this.selectedMembers.push(item.id)
      }
    }
  }
}
</script>