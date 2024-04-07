class JsonInput < ActiveAdminAddons::InputBase
  def render_custom_input
    concat(label_html)
    concat('<div class="jsoneditor-wrap">')
    concat(builder.hidden_field(method,
                                input_html_options.merge!(
                                  value: @object[method].to_json
                                )))
    concat('</div>')
  end
end