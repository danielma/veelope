module ApplicationHelper
  def render_errors(record)
    return if record.errors.empty?

    render partial: "shared/errors", locals: { errors: record.errors }
  end

  def return_to_path_hidden_field
    return unless return_to_path

    hidden_field_tag :return_to, return_to_path
  end

  def js_config
    {
      refreshing_connections: @refreshing_connections && @refreshing_connections.
        pluck(:institution_name),
      plaid: {
        env: AppConfig.plaid.env,
        api_version: "v2",
        client_name: "Envelope",
        key: AppConfig.plaid.public_key,
        product: ["transactions"],
      },
    }
  end

  def navigation_link_to(text, path, *args)
    if request.url == url_for(path)
      args[0] ||= {}

      if args.first[:class]
        args.first[:class] += " active"
      else
        args.first[:class] = "active"
      end
    end

    link_to(text, path, *args)
  end
end
