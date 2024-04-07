var initializer = function() {
  $('div.jsoneditor-wrap').each(function (i, wrap) {
    let fieldset = $(wrap).parents('li:eq(0)');
    let container = $(wrap)[0];
    let input = $($(wrap).find('input'));
    let editor;
    let options = {
      modes: ['tree', 'text'],
      mode: 'tree',
      onChange: function (ev) {
        try {
          let text = JSON.stringify(editor.get());
          input.val(text);
          $(fieldset).toggleClass('error', false);
        } catch (e) {
          console.log(e);
        }
      },
      onError: function (e) {
        $(fieldset).toggleClass('error', true);
      }
    };
    editor = new JSONEditor(container, options, JSON.parse(input.val()));
  });
};

$(initializer);
$(document).on('turbolinks:load', initializer);