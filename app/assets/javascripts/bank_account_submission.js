var marketplaceUri = '/v1/marketplaces/TEST-MP1TZWWqLLOetI0TpkD9CrMd';
var requestBinUrl = '/store_bank_account'

var debug = function(tag, content) {
  $('<' + tag + '>' + content + '</' + tag + '>').appendTo('#result');
};

try {
    balanced.init(marketplaceUri);
} catch (e) {
    debug('code', 'balanced.init error!');
}

function balancedCallback(response) {
    var tag = (response.status < 300) ? 'pre' : 'code';
    debug(tag, JSON.stringify(response));
    switch(response.status) {
        case 201:
            console.log(response.data);
            var $form = $("#bank-account-form");
            var bank_account_uri = response.data['uri'];
            $('<input>').attr({
                type: 'visible',
                value: bank_account_uri,
                name: 'balancedBankAccountURI'
            }).appendTo($form);
            $form.attr({action: requestBinUrl});
            $form.get(0).submit();
            break;
        case 400:
            console.log(response.error);
            break;
        case 404:
            console.log(response.error);
            break;
    }
}

var tokenizeBankAccount = function(e) {
    e.preventDefault();

    var $form = $('#bank-account-form');
    var bankAccountData = {
        name: $form.find('.ba-name').val(),
        account_number: $form.find('.ba-an').val(),
        bank_code: $form.find('.ba-rn').val(),
        type: $form.find('select').val()
    };

    balanced.bankAccount.create(bankAccountData, balancedCallback);
};

$(function(){
    $('#bank-account-form').submit(tokenizeBankAccount);
});
