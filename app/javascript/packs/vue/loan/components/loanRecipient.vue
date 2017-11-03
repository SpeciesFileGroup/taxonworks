<template>
    <div class="panel loan-box">
      <div class="header flex-separate middle">
        <h3 class="">Loan information</h3>
        <expand v-model="displayBody"></expand>
      </div>
      <div class="body horizontal-left-content align-start" v-if="displayBody">
        <div class="column-left">
          <span><b>Lender</b></span>
          <hr>
          <div class="field">
            <label>Lender address</label>
            <textarea v-model="loan.lender_address"></textarea>
          </div>
          <div class="field">
            <label>Request method</label>
            <input v-model="loan.request_method" type="text" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date requested</label>
            <input v-model="loan.date_requested" type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date sent</label>
            <input v-model="loan.date_sent" type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date received</label>
            <input v-model="loan.date_received" type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date return expected</label>
            <input v-model="loan.date_return_expected" type="date" class="normal-input"/>
          </div>
          <div class="field">
            <label>Date closed</label>
            <input v-model="loan.date_closed" type="date" class="normal-input"/>
          </div>
          <button type="button" class="button normal-input button-submit">Create Loan</button>
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
              <input v-model="loan.recipient_honorarium" type="text" class="normal-input"/>
            </div>
            <div class="field">
              <label>Address</label>
              <textarea v-model="loan.recipient_address" type="text"></textarea>
            </div>
          </div>
          <div class="separate-left">
            <div class="field">
              <label>Email </label>
              <input v-model="loan.recipient_email" type="text" class="normal-input"/>
            </div>
            <div class="field">
              <label>Phone</label>
              <input v-model="loan.recipient_phone" type="text" class="normal-input"/>
            </div>
            <div class="field">
              <label>Country</label>
              <input v-model="loan.recipient_country" type="text" class="normal-input"/>
            </div>
          </div>
          </div>
          <p><b>Supervisor</b></p>
          <hr/>
          <div class="field">
            <label>Email</label>
            <input v-model="loan.supervisor_email" type="text" class="normal-input"/>
          </div>
          <div class="field">
            <label>Phone</label>
            <input v-model="loan.supervisor_phone" type="text" class="normal-input"/>
          </div>
        </div>
      </div>
    </div>
</template>

<script>

  import rolePicker from '../../components/role_picker.vue';
  import expand from './expand.vue';

  import { GetterNames } from '../store/getters/getters';
  
  export default {
    components: {
      rolePicker,
      expand
    },
    computed: {
      getLoan: {
        get() {
          return this.$store.getters[GetterNames.GetLoan]
        }
      },
    },
    data: function() {
      return {
        displayBody: true,
        loan: {
          date_requested: undefined,
          request_method: undefined, 
          date_sent: undefined,
          date_received: undefined,
          date_return_expected: undefined, 
          recipient_person_id: undefined, 
          recipient_address: undefined,
          recipient_email: undefined, 
          recipient_phone: undefined,
          recipient_country: undefined,
          supervisor_person_id: undefined,
          supervisor_email: undefined, 
          supervisor_phone: undefined, 
          date_closed: undefined,
          recipient_honorarium: undefined,
          lender_address: undefined,
          clone_from: undefined
        }
      }
    },
    watch: {
      getLoan: function() {
        this.loan = this.getLoan;
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
    }
    textarea {
      header: 80px;
      min-height: 80px;
    }
  }
</style>