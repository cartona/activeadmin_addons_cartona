class TelInput < ActiveAdminAddons::InputBase
  def render_custom_input
    concat(label_html)
    virtual_attr = build_virtual_attr
    concat(builder.phone_field(virtual_attr, virtual_input_html_options(virtual_attr.to_s)))
  end

  def load_control_attributes
    opts = ActiveadminAddons.default_tel_options
    load_data_attr(:hidden_input, value: method.to_s)
    load_data_attr(:initial_country, default: opts[:initial_country])
    load_data_attr(:preferred_countries, default: opts[:preferred_countries])
  end

  def virtual_input_html_options(id)
    input_html_options.merge!({
                                id: id,
                                class: 'tel-input',
                                value: @object[method]
                              })
  end
end