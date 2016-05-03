$(document).ready(function(){
  var validate_bank_account = function() {
    var h_name = $("#ac_holder_name").val()
    var routing_num = $('#ac_routing_num').val();
    var ac_num = $("#ac_number").val();

    if (h_name != "" && routing_num != "" && ac_num != "") {
      bank_ac_obj = {
        'bank_code': routing_num,
        'account_number': ac_num,
        'name': h_name
      };
      validate_messages = balanced.bankAccount.validate(bank_ac_obj);
      console.log(validate_messages.length);

      if (validate_messages.length > 0) {
        alert(validate_messages[0].description);
        return false;
      }
      else{
        console.log('submitting now..')
        return true;
      }
    }
    else{
      alert("Please fill all bank details");
      return false;
    }
  }
  $('.add-bank-account-btn').on('click', function(e){
    e.preventDefault();
    var status = validate_bank_account();
    if(status == true){
      $('#bank_ac_form').submit();
    }
  });

  $('.admin-withdrawal-btn').click(function(e){
    e.preventDefault();
    var $amount = $('.withdraw-amount').val();
    if($.isNumeric($amount)){
      if(parseFloat($amount) === 0.0){
        $('.error-message-withdraw').html("Please enter a valid amount");
      }else{
        $('#admin_withdrawal_form').submit();
      }
    }else{
      $('.error-message-withdraw').html("Please enter amount");
    }
  });
});
