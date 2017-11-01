<template>
    <div class="panel loan-box">
      <div class="header flex-separate middle">
        <h3 class="">Information</h3>
        <expand v-model="displayBody"></expand>
      </div>
      <div class="body horizontal-left-content align-start" v-if="displayBody">
        <div class="column-left">
          <span><b>Lender</b></span>
          <hr>
          <div class="field">
            <label>Lender address</label>
            <textarea></textarea>
          </div>
          <div class="field">
            <label>Request method</label>
            <input type="text" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date requested</label>
            <input type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date sent</label>
            <input type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date received</label>
            <input type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date return expected</label>
            <input type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date closed</label>
            <input type="date" class="normal-input"/>
          </div>
        </div>

        <div class="column-right">
          <span><b>Recipient</b></span>
          <hr>
          <label>People</label>
          <role-picker></role-picker>
          <div class="horizontal-left-content">
            <div class="separate-right">
            <div class="field">
              <label>Honorarium</label>
              <input type="text" class="normal-input"/>
            </div>
            <div class="field">
              <label>Address</label>
              <textarea type="text"></textarea>
            </div>
          </div>
          <div class="separate-left">
            <div class="field">
              <label>Email </label>
              <input type="text" class="normal-input"/>
            </div>
            <div class="field">
              <label>Phone</label>
              <input type="text" class="normal-input"/>
            </div>
            <div class="field">
              <label>Country</label>
              <input type="text" class="normal-input"/>
            </div>
          </div>
          </div>
          <p><b>Supervisor</b></p>
          <hr/>
          <div class="field">
            <label>Email</label>
            <input type="text" class="normal-input"/>
          </div>
          <div class="field">
            <label>Phone</label>
            <input type="text" class="normal-input"/>
          </div>
        </div>
      </div>
    </div>
</template>

<script>
  import rolePicker from '../../components/role_picker.vue';
  import expand from './expand.vue';
  
  export default {
    components: {
      rolePicker,
      expand
    },
    data: function() {
      return {
        displayBody: true
      }
    }
  }
</script>

<style lang="scss">
  #edit_loan_task { 
    .column-left {
      width: 40%;
    }
    .column-right {
      //width: 50%;
    }
    textarea {
      header: 80px;
      min-height: 80px;
    }
  }
</style>