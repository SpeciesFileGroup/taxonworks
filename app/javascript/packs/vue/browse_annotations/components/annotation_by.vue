<template>
  <div>
          v-for="(member, key) in membersList"
    <button
        v-for="member in list[view]"
        :key="member.id"
        type="button"
        :class="{ ' button-submit': (membersList.hasOwnProperty(member.id))}"
        class="button normal-input button-default biocuration-toggle-button"
        @click="selectMember(member)"
        v-html="member.name"/>
  </div>
  <!--<span v-for="(member, key) in result"> {{ key }} : {{ member }} <br></span>-->
</template>

<script>
  export default {
    props: {

    },
    data: function () {
      return {
        membersList: undefined
      }
    },
    mounted: function () {
      this.$http.get('/project_members.json').then(response => {
        this.membersList = response.body.names
      })
    },
    methods: {
      selectMember(item) {
        if(this.membersList.hasOwnProperty(item.id)) {
          this.$delete(this.membersList, item.id)
        }
        else {
          this.$set(this.membersList, item.id, item);
        }
        this.$emit('input', this.membersList);
    }
  }
</script>