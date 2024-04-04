var initializer = function() {
  let telInputs = document.querySelectorAll(".tel-input");
  telInputs.forEach(function(telInput){
    window.intlTelInput(telInput, {
      utilsScript: '/assets/intlTelInput_utils.js',
      separateDialCode: true,
      hiddenInput: telInput.dataset.hiddenInput,
      initialCountry: telInput.dataset.initialCountry,
      preferredCountries: telInput.dataset.preferredCountries.split(',').map(c => c.trim())
    });
  });

};

$(initializer);
$(document).on('turbolinks:load', initializer);